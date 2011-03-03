require 'sinatra'
require 'yaml'

configure do
  DB = CouchRest.database!("#{ENV['CLOUDANT_URL']}/recharge")
  calendar = YAML.load_file('holidays/de_DE.yml')['de_DE']
  HOLIDAYS = calendar.inject({}) do |result, event|
    result[Date.parse(event.first)] = event.last
    result
  end
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
      css_classes = []
      css_classes << 'weekend' if weekend?(date)
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
end

get '/' do
  erb :index, :locals => {:vacation => [], :holidays => HOLIDAYS.keys.map(&:to_s)}
end

post '/' do
  response = DB.save_doc(:vacation => params[:vacation], :holidays => params[:holidays])
  content_type :json
  {:url => "/cal/#{response['id']}"}.to_json
end

get '/favicon.ico' do
  not_found
end

get '/cal/:calendar' do
  doc = DB.get(params[:calendar])
  erb :index, :locals => {
    :vacation => doc['vacation']['2011'],
    :holidays => doc['holidays']['2011']
  }
end

post '/cal/:calendar' do
  doc = DB.get(params[:calendar])
  doc['vacation']['2011'] = params[:vacation]['2011']
  doc['holidays']['2011'] = params[:holidays]['2011']
  response = DB.save_doc(doc)
  content_type :json
  {:url => "/cal/#{response['id']}"}.to_json
end
