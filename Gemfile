source 'http://rubygems.org'

gem 'rails', '3.0.10'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.2.11'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.5', :require => false, :group => [:development]
end

platforms :ruby_18 do
  gem 'system_timer'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
  gem 'rubyzip2'
  gem 'glassfish'
end

gem 'fastercsv' if RUBY_VERSION < '1.9'

gem 'will_paginate', '~> 3.0'
gem 'exception_notification', '~> 2.5.2'
gem 'delayed_job', '>= 2.1.4'
gem 'state_machine'
gem 'sunspot_rails', '~> 1.3.0.rc4'
gem 'sunspot_solr', '~> 1.3.0.rc4'
gem 'progress_bar'
gem "friendly_id", "~> 3.3"
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
gem 'strongbox', '>= 0.4.8'
gem 'acts-as-taggable-on', '~> 2.1'
gem 'dalli', '~> 1.1'
gem 'sitemap_generator', '~> 2.1'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail', '~> 2.3'
gem 'recurrence'
gem 'prism'
gem 'money'
gem 'RedCloth', '>= 4.2.8'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
gem 'attribute_normalizer'
gem 'configatron'
gem 'extractcontent'
gem 'cancan', '>= 1.6.5'
gem 'scribd_fu'
gem 'devise', '~> 1.4'
gem 'omniauth', '>= 0.2.6'
gem 'paperclip', '~> 2.4'
gem 'whenever', '~> 0.6', :require => false
gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'barby', '~> 0.5'
gem 'rqrcode'
gem 'event-calendar', :require => 'event_calendar'
gem 'jpmobile', '~> 1.0'
#gem 'geokit'
gem 'geocoder'
gem 'acts_as_list', :git => 'git://github.com/swanandp/acts_as_list.git'
gem 'library_stdnums'
gem 'client_side_validations'
gem 'simple_form', '~> 1.5'
gem 'validates_timeliness'
gem 'rack-protection'

#gem 'oink', '>=0.9.2'
group :development do
  gem 'parallel_tests'
  gem 'jquery-rails'
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 1.2'
  gem 'spork', '~> 0.9.0.rc9'
  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
end

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
#  gem 'sass-rails', "  ~> 3.1.0"
#  gem 'coffee-rails', "~> 3.1.0"
#  gem 'uglifier'
#end

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
