source 'https://rubygems.org'

ruby "1.9.3"

gem 'rails', '3.2.11'

gem 'cocaine', '0.4.2'
#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
#gem 'enju_nii', :git => 'git://github.com/nabeta/enju_nii.git'
gem 'enju_oai', '0.1.0.pre5'
gem 'enju_book_jacket', '0.1.0.pre2'
gem 'enju_manifestation_viewer', '0.1.0.pre3'
#gem 'enju_message', "0.1.14.pre"
gem 'enju_message', :git => 'git://github.com/shinozuka/enju_trunk_message.git'
gem "enju_ndl", "0.1.0.pre8"
#gem 'enju_ndl', :git => 'git://github.com/nabeta/enju_ndl.git'
#gem 'enju_question', :git => 'git://github.com/nabeta/enju_question.git'
gem 'enju_trunk_event', :git => 'git://github.com/shinozuka/enju_trunk_event.git', :require => 'enju_event'
#gem 'enju_bookmark', :git => 'git://github.com/nabeta/enju_bookmark'
#gem 'enju_bookmark', :git => 'git://github.com/shinozuka/enju_bookmark.git'
gem 'enju_subject', '~> 0.1.0.pre4'

gem "jpp_customercode_transfer", "~> 0.0.2"

# special gem here.
# gem 'enju_xxx', :git => 'https://xxx@github.com/'

#
platforms :ruby do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  ##gem 'ruby-prof', :group => [:development, :test]
  ##gem 'zipruby'
  gem 'kgio'
end

#platforms :ruby_19 do
#  gem 'simplecov', '~> 0.6', :require => false, :group => :test
#end

gem 'roo', "= 1.10.1"
gem 'spreadsheet', '0.7.9'
gem 'axlsx'

gem 'spinjs-rails'
gem 'kaminari'
gem 'settingslogic'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'exception_notification', '~> 2.5.2'
gem 'state_machine'
gem 'sunspot_rails', '~> 2.0.0.pre.120925'
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
gem 'RedCloth', '>= 4.2.9'
gem 'lisbn'
gem 'nori', '~> 2.0'
gem 'cancan', '>= 1.6.7'
gem 'scribd_fu'
gem 'devise', '~> 1.5'
gem 'omniauth', '>= 0.2.6'
gem 'addressable'
gem 'paperclip', '2.8'
gem 'whenever', '~> 0.6', :require => false

#aws
#gem 'aws-sdk', '~> 1.3'
#gem 'amazon-ecs', '>= 2.2.0', :require => 'amazon/ecs'
#gem 'aws-s3', :require => 'aws/s3'
#gem 'astrails-safe'

gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'attribute_normalizer', '~> 1.1'
gem 'barby', '~> 0.5'
gem 'chunky_png', '1.2.5'
#gem 'rghost', :branch => 'patch-ruby20', :git => 'git://github.com/nakamura-akifumi/rghost.git'
gem 'rghost'
gem 'rghost_barcode'
gem 'rqrcode'
gem 'event-calendar', :require => 'event_calendar'
gem 'geocoder'
#gem 'acts_as_list', :git => 'git://github.com/emiko/acts_as_list.git'
gem 'acts_as_list'
gem 'library_stdnums'
gem 'client_side_validations'
gem 'simple_form', '~> 1.5'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.0'
gem 'paranoia'
gem 'thinreports', :git => 'git://github.com/emiko/thinreports-generator.git'
gem 'prawn', '1.0.0.rc1'
gem "rmagick", :require => false
#gem "crypt19"
gem "rails_autolink"
gem 'parallel'
#gem 'oink', '>= 0.9.3'

group :development do
  gem 'parallel_tests'
  gem 'annotate'
  gem 'sunspot_solr', '~> 2.0.0.pre.120417'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.9'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 3.0'
  gem 'spork-rails'
  #gem 'rcov', '0.9.11'
  #gem 'metric_fu', '~> 2.1'
  gem 'timecop'
  #gem 'sunspot-rails-tester', :git => 'git://github.com/nabeta/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.0.0.rc2'
  gem 'fakeweb'
  #gem 'churn', '0.0.13'
  gem 'ci_reporter'
  gem 'database_cleaner'
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

# FRBR models
gem 'enju_trunk_frbr', :git => 'git://github.com/emiko/enju_trunk_frbr.git'

group :operation do
  gem 'enju_trunk_circulation', :git => 'git://github.com/emiko/enju_trunk_circulation.git'
  gem 'enju_trunk_ill', :git => 'git://github.com/emiko/enju_trunk_ill.git'
  gem 'enju_trunk_statistics', :git => 'git://github.com/emiko/enju_trunk_statistics.git'
end
