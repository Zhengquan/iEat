source 'http://rubygems.org'

gem 'rails', '3.2.9'
gem "devise", ">= 2.2.3"
gem "devise_invitable", ">= 1.1.5"

gem "cancan", ">= 1.6.8"
gem "rolify", ">= 3.2.0"
gem "figaro", ">= 0.5.3"

gem 'sqlite3'
gem "squeel"
gem "pg"
gem "activerecord-postgresql-adapter"

gem 'sprockets', '~> 2.0'
gem 'jquery-rails'
gem "simple_form", ">= 2.0.4"
gem "haml", ">= 3.1.7"
gem "libv8", ">= 3.11.8"
gem 'rabl-rails'
gem 'oj'
gem 'rack', '1.4.1'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem "less-rails", ">= 2.2.6"
  gem "twitter-bootstrap-rails", ">= 2.1.8"
  gem "therubyracer", ">= 0.11.3", :platform => :ruby, :require => "v8"
  gem "yui-compressor"
end

group :development do
  gem "ruby_parser", ">= 3.1.1"
  gem "quiet_assets", ">= 1.0.1"
  gem "better_errors", ">= 0.3.2"
  gem "binding_of_caller", ">= 0.6.8"
  # debugger
  gem 'pry'
  gem 'pry-debugger'
  gem 'awesome_print'
  gem 'pry-doc'
  gem 'pry-stack_explorer'

  gem "thin", ">= 1.5.0"
end

group :development, :test do
  gem "rspec-rails", ">= 2.12.2"
  gem "factory_girl_rails", ">= 4.2.0"
end

group :production do
  gem 'unicorn'
  gem 'daemon-spawn'
end

group :test do
  gem "capybara", ">= 2.0.2"
  gem "database_cleaner", ">= 0.9.1"
  gem "email_spec", ">= 1.4.0"
end
