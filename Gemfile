source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.9"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.2.2"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
# gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
# gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
# gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem 'devise'
gem 'pundit'
gem 'sunspot_rails', '~> 2.7'
gem 'acts_as_list'
gem 'kaminari'
gem 'strip_attributes'
gem 'statesman', '~> 12.1'
gem 'friendly_id'
gem 'globalize'
gem 'globalize-accessors'
gem 'date_validator'
gem 'browser'
gem 'lisbn'
gem 'library_stdnums'
gem 'geocoder'
gem 'awesome_nested_set'
gem 'dotenv-rails'
gem 'jquery-ui-rails', '~> 4.2.1'
gem 'cocoon'
gem 'jquery-rails'
gem 'addressable'
gem 'progress_bar'
gem 'rails_autolink'
gem 'kramdown'
gem 'solid_cache'
gem 'solid_queue', "~> 1.0"
gem 'mission_control-jobs', "~> 0.5.0"
gem 'acts-as-taggable-on'
gem 'resync' # , github: 'nabeta/resync', branch: 'add-datetime'
gem 'pretender'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'rails-i18n', '~> 7.0'
gem 'sitemap_generator'
gem 'rss'
gem 'rdf-turtle', require: 'rdf/turtle'
gem 'rdf-vocab', require: 'rdf/vocab'
gem 'oai'
gem 'active_storage_validations'
gem 'webpacker', '~> 5.0'
gem 'faraday-multipart'
gem 'nkf'

group :development, :test do
  gem 'annotaterb'
  gem 'database_consistency'
  gem 'rspec-rails'
  gem 'vcr'
  gem 'webmock'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'simplecov'
  gem 'parallel_tests'
  gem 'rspec_junit_formatter', require: false
end
