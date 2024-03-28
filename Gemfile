# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.3'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
gem "ruby-openai"
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 6.0'
gem 'sqids'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'boilerpipe-ruby', require: 'boilerpipe'
gem 'faraday'
gem 'nokogiri'
gem 'redcarpet'
gem 'turbo-rails', '~> 2.0.5'
gem 'validate_url'
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'draper'
gem 'jbuilder'
gem 'store_model', '~> 2.3'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'addressable'
gem 'bootsnap', require: false
gem 'haml'
gem 'js-routes'
gem 'public_suffix'
gem 'simple_form'

gem 'devise', git: 'https://github.com/heartcombo/devise.git', branch: '4-stable'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'
gem 'pagy', '~> 7.0'
gem 'rack-cors'

gem "avo", ">= 3.4.0"
gem 'propshaft'

gem 'ransack', github: 'activerecord-hackery/ransack', branch: 'main'
gem 'vite_rails'
# gem 'avo', '>= 3.0.1.beta9', source: 'https://packager.dev/avo-hq/'
# Use Sass to process CSS
# gem "sassc-rails"
gem 'dotenv-rails'
gem "down"
gem "image_processing", "~> 1.2"
gem "scenic"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'annotate'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'prettier'
  gem 'rspec-rails', '~> 6.0.3'

  gem 'rubocop', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem "fakeredis", require: "fakeredis/rspec"
  gem 'selenium-webdriver'
  gem "webmock"
end

gem 'good_job', '~> 3.19'

gem 'mjml-rails'
gem 'view_component', '~> 3.5'
