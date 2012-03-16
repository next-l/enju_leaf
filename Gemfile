source 'https://rubygems.org'

gem 'rails', '3.2.2'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
gem 'enju_barcode', :git => 'git://github.com/nabeta/enju_barcode.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', :git => 'git://github.com/nabeta/enju_ndl.git'
#gem 'enju_nii', :git => 'git://github.com/nabeta/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/nabeta/enju_oai.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', :git => 'git://github.com/nabeta/enju_subject.git'
gem 'enju_purchase_request', :git => 'git://github.com/nabeta/enju_purchase_request.git'
gem 'enju_question', :git => 'git://github.com/nabeta/enju_question.git'
gem 'enju_bookmark', :git => 'git://github.com/nabeta/enju_bookmark.git'
gem 'enju_resource_merge', :git => 'git://github.com/nabeta/enju_resource_merge.git'
gem 'enju_circulation', :git => 'git://github.com/nabeta/enju_circulation.git'
gem 'enju_message', :git => 'git://github.com/nabeta/enju_message.git'
gem 'enju_inter_library_loan', :git => 'git://github.com/nabeta/enju_inter_library_loan.git'
gem 'enju_inventory', :git => 'git://github.com/nabeta/enju_inventory.git'
gem 'enju_event', :git => 'git://github.com/nabeta/enju_event.git'
#gem 'enju_news', :git => 'git://github.com/nabeta/enju_news.git'
gem 'enju_search_log', :git => 'git://github.com/nabeta/enju_search_log.git'
gem 'enju_book_jacket', :git => 'git://github.com/nabeta/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/nabeta/enju_manifestation_viewer.git'

platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'ruby-prof', :group => [:development, :test]
  gem 'zipruby'
  gem 'kgio'
end

platforms :ruby_19 do
  gem 'simplecov', '~> 0.6', :require => false, :group => :test
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
gem 'configatron'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'state_machine', '~> 1.1.2'
gem 'sunspot_rails', :git => 'git://github.com/sunspot/sunspot.git'
gem 'sunspot_solr',  :git => 'git://github.com/sunspot/sunspot.git'
gem 'progress_bar'
gem 'friendly_id', '~> 4.0'
gem 'inherited_resources', '~> 1.3'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
#gem 'attr_encryptor'
gem 'dalli', '~> 1.1'
gem 'sitemap_generator', '~> 3.0'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail', '~> 2.6'
#gem 'recurrence'
#gem 'prism'
#gem 'money'
gem 'RedCloth', '>= 4.2.9'
gem 'isbn-tools', :git => 'git://github.com/nabeta/isbn-tools.git', :require => 'isbn/tools'
#gem 'extractcontent'
gem 'cancan', '>= 1.6.7'
gem 'devise', '~> 2.0'
gem 'omniauth', '~> 1.0'
gem 'addressable'
gem 'paperclip', '~> 2.7'
gem 'aws-sdk', '~> 1.3'
gem 'whenever', :require => false
#gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
#gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'attribute_normalizer', '~> 1.1'
#gem 'geokit'
gem 'geocoder'
gem 'acts_as_list', '~> 0.1.5'
gem 'library_stdnums'
gem 'client_side_validations', '~> 3.2.0.beta.3'
gem 'simple_form', '~> 2.0'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
#gem 'oink', '>= 0.9.3'

#group :production do
#  gem 'vidibus-routing_error'
#end

group :development do
  gem 'parallel_tests', '~> 0.7'
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.9.0.rc2'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 2.0.0.rc'
  gem 'spork-rails'
  gem 'rcov', '0.9.11'
  gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.0'
  gem 'fakeweb'
  gem 'churn', '0.0.13'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'
