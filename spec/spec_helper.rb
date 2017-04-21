require 'rubygems'
require 'bundler'
require 'capybara/rspec'

Bundler.require(:default, :test)

require File.expand_path('../../recharge', __FILE__)

set :environment, :test

Capybara.app = Sinatra::Application

RSpec.configure do |config|
  config.include(Rack::Test::Methods)

  def app
    Sinatra::Application
  end
end