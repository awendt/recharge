# encoding: UTF-8
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'couchrest'
require 'yaml'
require 'rack/csrf'
require 'holidays'
require 'holidays/de'
require_relative './database'

configure :production do
  set :db, "#{ENV['CLOUDANT_URL']}/recharge"
  use Rack::Csrf, :raise => true
  require 'newrelic_rpm'
end

configure :test do
  set :db, ENV['RECHARGE_TEST_DB'] || 'http://localhost:5984/recharge_test'
end

configure :cucumber do
  set :db, ENV['RECHARGE_TEST_DB'] || 'http://localhost:5984/recharge_test'
  use Rack::Csrf, :raise => true
end

configure :development do
  set :db, ENV['RECHARGE_DEV_DB'] || 'http://localhost:5984/recharge_development'
end

enable :sessions
set :session_secret, ENV['SESSION_KEY']

set :views, './views'
set :public_folder, File.dirname(__FILE__) + '/public'

use Rack::Deflater

class Date
  def to_s
    strftime('%Y%m%d')
  end
end

helpers do
  def db
    @db ||= CouchRest.database(settings.db)
  end

  def holidays_in(year, region)
    first_day = Date.ordinal(year, 1)
    last_day = Date.ordinal(year, -1)
    holidays = Holidays.between(first_day, last_day, region.to_sym).inject({}) do |result, holiday|
      result[holiday[:date].to_s] = holiday[:name]
      result
    end
  end

  def calendar_for(year, vacation, active_holidays)
    first = Date.ordinal(year, 1)
    last = Date.ordinal(year, -1)
    holidays = holidays_in(year, :de)
    cal = [%(<table border="0" cellspacing="0" cellpadding="0">)]
    cal << %(<tbody>)
    first.upto(last) do |date|
      month = date.month
      timestamp = date.to_s
      if date.day == 1
        cal << %(<tr id="#{date.year}#{'%02d' % month}">)
        cal << %(<th>#{month_name_for(month)}</th>)
      end
      next if date.saturday? || date.sunday?
      css_classes = []
      css_classes << 'monday' if date.monday?
      css_classes << 'friday' if date.friday?
      if vacation.key?(timestamp)
        css_classes << 'vacation'
        css_classes << 'half' if vacation[timestamp] == 0.5
      end
      if holidays.key?(timestamp)
        css_classes << 'holiday'
        title = holidays[timestamp]
      else
        title = ""
      end
      css_classes << 'active' << 'holiday' if active_holidays.include?(timestamp)
      cal << %(<td id="#{timestamp}" class="#{css_classes.join(' ')}" title="#{title}">#{date.day}</td>)
      cal << %(</tr>) if date.succ.month != month
    end
    cal << %(</tbody>)
    cal << %(</table>)
    cal.join("\n")
  end

  def id_for(*args)
    case args.size
    when 2 then "#{args[0]}#{"%02d" % args[1]}"
    else "#{args[0]}#{"%02d" % args[1]}#{"%02d" % args[2]}"
    end
  end

  def month_name_for(month)
    %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez)[month-1]
  end

  def button_label
    case request.fullpath
    when '/', %r(^/20[0-9]{2}$)
      "Kalender behalten"
    else
      "Kalender aktualisieren"
    end
  end

  def halt_on_empty_vacation
    halt 406, "Please mark anything as your vacation!" if !params[:vacation] ||
        params[:vacation].empty?
  end

  def csrf_token
    Rack::Csrf.csrf_token(env)
  end

  def meta_tag_noindex
    '<meta name="robots" content="noindex">' unless request.fullpath == '/'
  end

  def on_saved_calendar?
    request.fullpath =~ /^\/cal\//
  end

  def calendar_url
    calendar_path = "/ics/#{params[:calendar]}"
    "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}#{calendar_path}"
  end

  def link_to_icalendar_export
    if on_saved_calendar?
      %Q!<button id="copy" class="btn" rel="popover" data-title="Diesen Kalender abonnieren" data-content="Mit dieser Adresse kann der Kalender in Programmen wie iCal, Outlook oder Sunbird abonniert werden."><i class="icon-calendar"></i> Kalenderadresse kopieren</button>!
    else
      '&nbsp;'
    end
  end

  def link_to_previous_year(year)
    previous_year = year - 1
    target_path = if request.path_info =~ %r(\/#{year}$)
      request.path_info.gsub(%r(\/#{year}$), "/#{previous_year}")
    else
      request.path_info + "/#{previous_year}"
    end.gsub(%r(//), '/')
    %Q(<a id="previous" class="btn btn-primary" href="#{target_path}">← #{previous_year}</a>)
  end

  def link_to_next_year(year)
    next_year = year + 1
    target_path = if request.path_info =~ %r(\/#{year}$)
      request.path_info.gsub(%r(\/#{year}$), "/#{next_year}")
    else
      request.path_info + "/#{next_year}"
    end.gsub(%r(//), '/')
    %Q(<a id="next" class="btn btn-primary" href="#{target_path}">#{next_year} →</a>)
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

  def show_cal(name, vacation, holidays, year)
    erb :index, :locals => {vacation: vacation, holidays: holidays, year: year,
        name: name}
  end

  def page_title(name)
    if on_saved_calendar?
      "#{name} — Recharge"
    else
      "Recharge — kostenloser Online-Urlaubsplaner ohne Excel"
    end
  end
end

get '/:year?' do
  expires 300, :public, :must_revalidate
  year = (params[:year] || Time.now.year).to_i
  first = Date.ordinal(year, 1)
  last = Date.ordinal(year, -1)
  show_cal('Recharge', {}, Holidays.between(first, last, :de).map{|h| h[:date].to_s}, year)
end

post '/:year?' do |year|
  halt_on_empty_vacation
  id = SecureRandom.hex
  Database.instance.put(id: id, year: year || Time.now.year, vacation: params[:vacation])
  content_type :json
  url = "/cal/#{id}"
  url += "/#{params[:year]}" if params[:year]
  response.set_cookie(url.gsub(%r(/), '_'), 'show_bookmark_hint')
  {:url => url}.to_json
end

get '/cal/:calendar/?:year?' do |cal, year|
  doc = (Database.instance.get(id: cal, year: year || Time.now.year) || {'vacation' => {}}).merge('holidays' => {})
  year ||= Time.now.year.to_s
  first = Date.ordinal(year.to_i, 1)
  last = Date.ordinal(year.to_i, -1)
  show_cal(doc['name'] || 'Mein Kalender', doc['vacation'] || {},
      doc['holidays'][year] || Holidays.between(first, last, :de).map{|h| h[:date].to_s}, year.to_i)
end

post '/cal/:calendar/?:year?' do |cal, year|
  halt_on_empty_vacation
  Database.instance.put(id: cal, year: year || Time.now.year, vacation: params[:vacation])
  content_type :json
  url = "/cal/#{cal}"
  url += "/#{year}" if year
  {:url => url}.to_json
end

put '/cal/:calendar/name' do
  doc = db.get(params[:calendar])
  doc['name'] = params[:name]
  response = db.save_doc(doc)
  content_type :json
  {name: db.get(response['id'])['name']}.to_json
end

get '/ics/:calendar' do |cal|
  doc = Database.instance.get_all(id: cal)
  name = 'Recharge'
  calendar = Icalendar::Calendar.new
  calendar.custom_property("X-WR-CALNAME", name)
  doc.items.each do |by_year|
    ranges_from(by_year['vacation'].keys.sort).each do |vacation|
      calendar.event do
        dtstart Date.parse(vacation.begin)
        dtend Date.parse(vacation.last).succ
        summary name
      end
    end
  end
  content_type :ics
  calendar.to_ical
end

get '/holidays/:region/:year' do |region, year|
  begin
    etag "#{region}-#{year}"
    content_type :json
    holidays_in(year.to_i, region).to_json
  rescue Holidays::UnknownRegionError
    not_found
  end
end
