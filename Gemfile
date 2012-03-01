source 'https://rubygems.org'

gem 'rails', '3.2.1'

#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
#gem 'enju_nii', :git => 'git://github.com/nabeta/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/nabeta/enju_oai.git'
gem 'enju_book_jacket', :git => 'git://github.com/nabeta/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/nabeta/enju_manifestation_viewer.git'
gem 'enju_ndl', :git => 'git://github.com/nabeta/enju_ndl.git'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.6', :require => false, :group => :test
end

gem 'will_paginate', '~> 3.0'
gem 'configatron'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'exception_notification', '~> 2.5.2'
gem 'state_machine'
gem 'sunspot_rails', '~> 1.3'
gem 'sunspot_solr', '~> 1.3'
gem 'progress_bar'
gem 'friendly_id', '~> 4.0'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
#gem 'marc'
#gem 'strongbox', '>= 0.4.8'
gem 'acts-as-taggable-on', '~> 2.2'
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
#gem 'extractcontent'
gem 'cancan', '>= 1.6.7'
gem 'scribd_fu'
gem 'devise', '~> 1.5'
gem 'omniauth', '>= 0.2.6'
gem 'addressable'
gem 'paperclip', '~> 2.6'
gem 'whenever', '~> 0.6', :require => false
#gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
#gem 'aws-s3', :require => 'aws/s3'
#gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'attribute_normalizer', '~> 1.1'
gem 'barby', '~> 0.5'
gem 'rghost'  
gem 'rghost_barcode'  
gem 'rqrcode'
gem 'event-calendar', :require => 'event_calendar'
gem 'geocoder'
gem 'acts_as_list', :git => 'git://github.com/emiko/acts_as_list.git'
gem 'library_stdnums'
gem 'client_side_validations'
gem 'simple_form', '~> 1.5'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.0'
gem 'paranoia'
gem 'thinreports'
gem "rmagick", :require => false
gem "crypt19"
#gem 'oink', '>= 0.9.3'

group :development do
  gem 'parallel_tests'
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.8.1'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 1.7'
  gem 'spork-rails'
  gem 'rcov', '0.9.11'
  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester'
  gem 'vcr', '~> 2.0.0.rc2'
  gem 'fakeweb'
  gem 'churn', '0.0.13'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
   gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'


# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug19', :require => 'ruby-debug'

