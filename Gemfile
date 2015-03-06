source 'https://rubygems.org'
group :production do
  ruby '1.9.3'
end

gem 'sinatra'
gem 'rack_csrf', :require => 'rack/csrf'
gem 'couchrest'
gem 'icalendar'
gem 'holidays'
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
  gem "rack-test"
  gem "webrat"
  gem 'cucumber'
  gem 'cucumber-sinatra'
  gem 'capybara', '<2.1'
end
