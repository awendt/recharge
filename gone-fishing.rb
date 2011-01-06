require 'sinatra'

set :views, './views'
set :public, File.dirname(__FILE__) + '/public'

get '/' do
  erb :index
end