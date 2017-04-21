require 'rubygems'
require 'bundler'
require 'capybara/rspec'

Bundler.require(:default, :test)

require File.expand_path('../../recharge', __FILE__)
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

set :environment, :test

Capybara.app = Rack::Builder.parse_file(File.expand_path('../../config.ru', __FILE__)).first

RSpec.configure do |config|
  config.include(Rack::Test::Methods)

  def app
    Sinatra::Application
  end
end
