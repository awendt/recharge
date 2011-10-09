# Generated by cucumber-sinatra. (Sat Oct 01 19:57:01 +0200 2011)

ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '..', '..', 'recharge.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'

Capybara.app = Sinatra::Application

class RechargeWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers

  def db
    @db ||= CouchRest.database(settings.db)
  end
end

Before do
  db.delete!
  db.create!
end

World do
  RechargeWorld.new
end
