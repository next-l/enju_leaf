source 'https://rubygems.org'

gem 'rails', '3.1.3'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
gem 'enju_barcode', '0.0.1'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', '>= 0.0.6'
#gem 'enju_nii', :git => 'git://github.com/nabeta/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/nabeta/enju_oai.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', '0.0.6'
gem 'enju_purchase_request', '0.0.4'
gem 'enju_question', '0.0.5'
gem 'enju_bookmark', '0.0.4'
gem 'enju_resource_merge', '0.0.3'
gem 'enju_circulation', '0.0.7'
gem 'enju_message', '0.0.7'
#gem 'enju_inter_library_loan', '>= 0.0.1'
gem 'enju_inventory', '0.0.3'
gem 'enju_event', '0.0.5'
#gem 'enju_news', :git => 'git://github.com/nabeta/enju_news.git'
gem 'enju_search_log', '0.0.2'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.5', :require => false, :group => :test
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
gem 'delayed_job_active_record'
gem 'daemons'
gem 'state_machine'
gem 'sunspot_rails', '~> 1.3'
gem 'sunspot_solr', '~> 1.3'
gem 'progress_bar'
gem 'friendly_id', '~> 4.0'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
#gem 'strongbox', '>= 0.5'
gem 'dalli', '~> 1.1'
gem 'sitemap_generator', '~> 3.0'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail', '~> 2.6'
gem 'aws-sdk', '~> 1.3'
#gem 'recurrence'
#gem 'prism'
#gem 'money'
gem 'RedCloth', '>= 4.2.9'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
gem 'configatron'
gem 'extractcontent'
gem 'cancan', '>= 1.6.7'
gem 'devise', '~> 1.5.3'
gem 'omniauth', '~> 1.0'
gem 'addressable'
gem 'paperclip', '~> 2.5'
gem 'whenever', :require => false
#gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
#gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'jpmobile', '~> 2.0', :require => false
gem 'attribute_normalizer', '~> 1.0'
#gem 'geokit'
gem 'geocoder'
gem 'acts_as_list', :git => 'git://github.com/swanandp/acts_as_list.git'
gem 'library_stdnums'
gem 'client_side_validations'
gem 'simple_form', '~> 1.5'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.0'
gem 'rails_autolink'
#gem 'oink', '>= 0.9.3'

group :production do
  gem 'vidibus-routing_error', :git => 'git://github.com/nabeta/vidibus-routing_error.git'
end

group :development do
  gem 'parallel_tests'
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.8.1'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 1.6'
  gem 'spork', '~> 0.9'
  gem 'rcov', '0.9.11'
  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester'
  gem 'vcr', '~> 2.0.0.rc1'
  gem 'fakeweb'
  gem 'churn', '0.0.13'
end

# Gems used only for assets and not required
# in production environments by default.
#group :assets do
#  gem 'sass-rails',   '~> 3.1.5'
#  gem 'coffee-rails', '~> 3.1.1'
#
#  gem 'uglifier', '>= 1.0.3'
#end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

group :test do
  # Pretty printed test output
  gem 'turn', '~> 0.8.3', :require => false
end
