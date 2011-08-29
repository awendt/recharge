require 'sinatra'
require 'yaml'
require 'rack/csrf'

configure do
  DB = CouchRest.database("#{ENV['CLOUDANT_URL']}/recharge")
  calendar = YAML.load_file('holidays/de_DE.yml')['de_DE']
  HOLIDAYS = calendar.inject({}) do |result, event|
    result[Date.parse(event.first)] = event.last
    result
  end
end

enable :sessions

configure :production do
  use Rack::Csrf, :raise => true
end

set :views, './views'
set :public, File.dirname(__FILE__) + '/public'

class Date
  def to_s
    strftime('%Y%m%d')
  end
end

helpers do
  def calendar_for(year, vacation, active_holidays)
    first = Date.ordinal(year, 1)
    last = Date.ordinal(year, -1)
    cal = [%(<table border="0" cellspacing="0" cellpadding="0">)]
    cal << %(<tbody>)
    first.upto(last) do |date|
      if date.day == 1
        cal << %(<tr id="#{date.year}#{'%02d' % date.mon}">)
        cal << %(<th>#{month_name_for(date.mon)}</th>)
      end
      next if weekend?(date)
      css_classes = []
      css_classes << 'monday' if monday?(date)
      css_classes << 'friday' if friday?(date)
      css_classes << 'holiday' if holiday?(date)
      css_classes << 'active' if active_holidays.include?(date.to_s)
      css_classes << 'vacation' if vacation.include?(date.to_s)
      title = holiday?(date) ? HOLIDAYS[date] : ""
      cal << %(<td id="#{date}" class="#{css_classes.join(' ')}" title="#{title}">#{date.day}</td>)
      cal << %(</tr>) if date == Date.new(date.year, date.month, -1)
    end
    cal << %(</tbody>)
    cal << %(</table>)
    cal.join("\n")
  end

  def monday?(time)
    time.wday == 1
  end

  def friday?(time)
    time.wday == 5
  end

  def weekend?(time)
    [0,6].include?(time.wday)
  end

  def id_for(*args)
    case args.size
    when 2 then "#{args[0]}#{"%02d" % args[1]}"
    else "#{args[0]}#{"%02d" % args[1]}#{"%02d" % args[2]}"
    end
  end

  def holiday?(date)
    HOLIDAYS.keys.include?(date)
  end

  def month_name_for(month)
    %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez)[month-1]
  end

  def button_label
    case request.fullpath
    when '/', %r(^/20[0-9]{2}$)
      "Save"
    else
      "Update"
    end
  end

  def halt_on_empty_vacation
    halt 406, "Please mark anything as your vacation!" \
        if !params[:vacation] || params[:vacation].empty? || params[:vacation]['2011'].empty?
  end

  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def clippy(text, bgcolor='#FFFFFF')
    html = <<-EOF
      <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
              width="110"
              height="14"
              id="clippy" >
      <param name="movie" value="/clippy.swf"/>
      <param name="allowScriptAccess" value="always" />
      <param name="quality" value="high" />
      <param name="scale" value="noscale" />
      <param NAME="FlashVars" value="text=#{text}">
      <param name="bgcolor" value="#{bgcolor}">
      <embed src="/clippy.swf"
             width="110"
             height="14"
             name="clippy"
             quality="high"
             allowScriptAccess="always"
             type="application/x-shockwave-flash"
             pluginspage="http://www.macromedia.com/go/getflashplayer"
             FlashVars="text=#{text}"
             bgcolor="#{bgcolor}"
      />
      </object>
    EOF
  end

  def link_to_icalendar_export
    calendar_path = "/ics/#{params[:calendar]}"
    calendar_url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{calendar_path}"
    %Q!<span id="ics"><a href="#{calendar_path}">Calendar URL</a>#{clippy(calendar_url)}</span>! \
        if request.fullpath =~ /^\/cal\//
  end

  def ranges_from(array)
    ranges = []
    left, right = array.first, nil
    array.each do |obj|
      if right && obj != right.succ
        ranges << Range.new(left,right)
        left = obj
      end
      right = obj
    end
    ranges << Range.new(left,right)
  end

  def default_params
    {:vacation => [], :holidays => HOLIDAYS.keys.map(&:to_s), :year => Time.now.year}
  end
end

get '/' do
  erb :index, :locals => default_params
end

get '/:year' do |year|
  erb :index, :locals => default_params.merge(:year => year.to_i)
end

post '/' do
  halt_on_empty_vacation
  response = DB.save_doc(:vacation => params[:vacation], :holidays => params[:holidays])
  content_type :json
  {:url => "/cal/#{response['id']}"}.to_json
end

get '/favicon.ico' do
  not_found
end

get '/cal/:calendar' do |cal|
  doc = DB.get(cal)
  erb :index, :locals => default_params.merge(:vacation => doc['vacation']['2011'],
      :holidays => doc['holidays']['2011'])
end

post '/cal/:calendar' do
  halt_on_empty_vacation
  doc = DB.get(params[:calendar])
  doc['vacation']['2011'] = params[:vacation]['2011']
  doc['holidays']['2011'] = params[:holidays]['2011']
  response = DB.save_doc(doc)
  content_type :json
  {:url => "/cal/#{response['id']}"}.to_json
end

get '/ics/:calendar' do
  doc = DB.get(params[:calendar])
  calendar = Icalendar::Calendar.new
  calendar.custom_property("X-WR-CALNAME", "Vacation")
  ranges_from(doc['vacation']['2011']).each do |vacation|
    calendar.event do
      dtstart Date.parse(vacation.begin)
      dtend Date.parse(vacation.last).succ
      summary 'Vacation'
    end
  end
  content_type :ics
  calendar.to_ical
end