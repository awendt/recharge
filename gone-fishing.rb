require 'sinatra'

set :views, './views'
set :public, File.dirname(__FILE__) + '/public'

helpers do
  def calendar_for(year)
    erb :_calendar, :layout => false, :locals => {:year => year}
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

  def month_name_for(month)
    %w(Jan Feb Mär Apr Mai Jun Jul Aug Sep Okt Nov Dez)[month-1]
  end
end

get '/' do
  erb :index
end