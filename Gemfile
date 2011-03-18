source 'http://rubygems.org'

gem 'rails', '3.0.5'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

platforms :ruby do
  gem 'pg'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
end

platforms :ruby_19 do
  gem 'simplecov', :require => false, :group => :test
end

platforms :ruby_18 do
  gem 'system_timer'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
  gem 'rubyzip'
  gem 'glassfish'
end

gem 'fastercsv' if RUBY_VERSION < '1.9'

gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
gem 'exception_notification', :git => 'git://github.com/rails/exception_notification.git', :require => 'exception_notifier'
gem 'delayed_job', '>=2.1.3'
gem 'state_machine'
gem 'prawn'
gem 'sunspot_rails', '>=1.2.1'
gem 'friendly_id'
gem 'inherited_resources'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
gem 'strongbox', '>=0.4.5'
gem 'acts-as-taggable-on'
gem 'dalli'
gem 'sitemap_generator'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail', '>=2.0.2'
gem 'recurrence'
gem 'prism'
gem 'money'
gem 'geocoder', '>=0.9.10'
gem 'RedCloth', '>=4.2.7'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
gem 'attribute_normalizer'
gem 'configatron'
gem 'extractcontent'
gem 'cancan', '>=1.6.2'
gem 'scribd_fu', :git => 'git://github.com/nabeta/scribd_fu.git'
gem 'devise'
gem 'omniauth'
gem 'paperclip'
gem 'whenever', :require => false
gem 'amazon-ecs', :require => 'amazon/ecs'
gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'
gem 'dynamic_form'
gem 'formtastic'
gem 'jquery-rails'
gem 'sanitize'
gem 'barby'
gem 'prawnto'

gem 'oink'
gem 'parallel_tests', :group => :development

group :development, :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'guard-rspec'
  gem 'factory_girl_rails'
  gem 'spork', '~> 0.9.0.rc4'
end

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
