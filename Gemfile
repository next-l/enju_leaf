source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 6.1.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use Puma as the app server
gem 'puma', '~> 5.0'
# Use SCSS for stylesheets
gem 'sass-rails', '>= 6'
# Transpile app-like JavaScript. Read more: https://github.com/rails/webpacker
gem 'webpacker', '~> 5.0'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Active Storage variant
gem 'image_processing', '~> 1.2'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.4', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 4.1.0'
  # Display performance information such as SQL time and flame graphs for each request in your browser.
  # Can be configured to work on production as well see: https://github.com/MiniProfiler/rack-mini-profiler/blob/master/README.md
  gem 'rack-mini-profiler', '~> 2.0'
  gem 'listen', '~> 3.3'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 3.26'
  gem 'selenium-webdriver'
  # Easy installation and use of web drivers to run system tests with browsers
  gem 'webdrivers'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'
gem 'pundit'
gem 'sunspot_rails'
gem 'paperclip'
gem 'paperclip-meta'
gem 'acts_as_list'
gem 'kaminari'
gem 'strip_attributes'
gem 'statesman', '~> 10.1.0'
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
gem 'faraday_middleware'
gem 'kramdown'
gem 'resque', require: 'resque/server'
gem 'sassc', '~> 2.1.0'
gem 'acts-as-taggable-on'
gem 'resync' # , github: 'nabeta/resync', branch: 'add-datetime'
gem 'pretender'
gem 'caxlsx'
gem 'caxlsx_rails'
gem 'rails-i18n', '~> 6.0'
gem 'sitemap_generator'
gem 'rdf-turtle', require: 'rdf/turtle'
gem 'rdf-vocab', require: 'rdf/vocab'
gem 'oai'
gem 'mail', '~> 2.7.1'

group :development, :test do
  gem 'annotate'
end

group :test do
  gem 'rspec-rails'
  gem 'vcr'
  gem 'webmock'
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'simplecov'
  gem 'parallel_tests'
  gem 'rspec_junit_formatter', require: false
end
