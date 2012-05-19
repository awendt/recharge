require 'rubygems'
require 'bundler'

Bundler.require(:default, :test)

require File.expand_path('../../recharge', __FILE__)

set :environment, :test

Webrat.configure do |config|
  config.mode = :rack
  config.application_port = 4567
end

RSpec.configure do |config|
  config.include(Rack::Test::Methods)
  config.include(Webrat::Methods)
  config.include(Webrat::Matchers)

  def app
    Sinatra::Application
  end
end