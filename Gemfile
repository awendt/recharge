source 'https://rubygems.org'

gem 'sinatra'
gem 'rack_csrf', :require => 'rack/csrf'
gem 'couchrest'
gem 'icalendar', '1.3.0' # upgrading breaks our usage of custom_property and dtstart
gem 'holidays', '1.0.5' # upgrading breaks require 'holidays/de'
gem 'newrelic_rpm'
gem 'thin'

gem 'sprockets'
gem 'yui-compressor', :require => 'yui/compressor'
gem 'uglifier'
gem 'therubyracer'

group :development do
  gem 'rake'
end

group :test do
  gem "rspec"
  gem 'rspec-its'
  gem "rack-test"
  gem 'cucumber'
  gem 'cucumber-sinatra'
  gem 'capybara'
  gem 'selenium-webdriver'
end
