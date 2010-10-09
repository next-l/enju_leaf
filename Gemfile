source 'http://rubygems.org'

gem 'rails', '3.0.0'

# Bundle edge Rails instead:
#gem 'rails', :git => 'git://github.com/rails/rails.git'

if defined?(JRUBY_VERSION)
  gem 'jruby-openssl'
  gem 'activerecord-jdbc-adapter'
  gem 'jdbc-postgres', :require => false
  #gem 'jdbc-mysql', :require => false
else
  gem 'pg'
  #gem 'mysql'
  gem 'formatize'
  gem 'zipruby'
end
gem 'will_paginate', :git => 'git://github.com/mislav/will_paginate.git', :branch => 'rails3'
gem 'delayed_job', :git => 'git://github.com/collectiveidea/delayed_job.git'
gem 'exception_notification', :git => 'git://github.com/rails/exception_notification.git', :require => 'exception_notifier'
gem 'state_machine' #, :git => 'git://github.com/pluginaweek/state_machine.git'
gem 'prawn' #, :git => 'git://github.com/sandal/prawn.git'
gem 'sunspot_rails', '1.2.rc4'
unless RUBY_VERSION > '1.9'
  gem 'fastercsv'
  gem 'system_timer' unless defined?(JRUBY_VERSION)
end
gem 'friendly_id'
gem 'inherited_resources'
gem 'has_scope'
gem 'nokogiri'
gem 'marc'
gem 'strongbox', '>=0.4.1'
gem 'warden'
gem 'warden_oauth'
gem 'acts-as-taggable-on'
gem 'memcache-client'
gem 'sitemap_generator'
gem 'ri_cal'
gem 'file_wrapper'
gem 'paper_trail'
gem 'recurrence'
gem 'prism'
gem 'money'
gem 'rails-geocoder', :require => 'geocoder'
gem 'RedCloth'
gem 'isbn-tools', :require => 'isbn/tools'
gem 'rack-openid', :require => 'rack/openid'
gem 'attribute_normalizer'
gem 'configatron'
gem 'extractcontent'
gem 'cancan', '>=1.4.0'
gem 'scribd_fu', :git => 'git://github.com/nabeta/scribd_fu.git'
gem 'devise'
gem 'paperclip'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'whenever', :require => false
gem 'amazon-ecs', :require => 'amazon/ecs'
gem 'aws-s3', :require => 'aws/s3'
gem 'astrails-safe'

gem 'oink'
gem 'simplecov', :require => false if RUBY_VERSION > '1.9'

# Use unicorn as the web server
gem 'unicorn' unless defined?(JRUBY_VERSION)

# Deploy with Capistrano
# gem 'capistrano'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri', '1.4.1'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for certain environments:
# gem 'rspec', :group => :test
# group :test do
#   gem 'webrat'
# end
