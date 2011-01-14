require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require 'gone-fishing'

set :environment, :test

Webrat.configure do |config|
  config.mode = :rack
  config.application_port = 4567
end

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)

  config.before(:each) do
  end

  def app
    Sinatra::Application
  end
end