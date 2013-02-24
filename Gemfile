source 'https://rubygems.org'

ruby '2.0.0'
gem 'rails', '3.2.12'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_core', :git => 'git://github.com/next-l/enju_core.git'
gem 'enju_biblio', :git => 'git://github.com/next-l/enju_biblio.git'
gem 'enju_library', :git => 'git://github.com/next-l/enju_library.git'
#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_barcode', :git => 'git://github.com/nabeta/enju_barcode.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', :git => 'git://github.com/next-l/enju_ndl.git'
gem 'enju_nii', :git => 'git://github.com/next-l/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/next-l/enju_oai.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', :git => 'git://github.com/next-l/enju_subject.git'
#gem 'enju_purchase_request', :git => 'git://github.com/next-l/enju_purchase_request.git'
#gem 'enju_question', :git => 'git://github.com/next-l/enju_question.git'
#gem 'enju_bookmark', :git => 'git://github.com/next-l/enju_bookmark.git'
gem 'enju_resource_merge', :git => 'git://github.com/next-l/enju_resource_merge.git'
gem 'enju_circulation', :git => 'git://github.com/next-l/enju_circulation.git'
#gem 'enju_message', :git => 'git://github.com/next-l/enju_message.git'
gem 'enju_inter_library_loan', :git => 'git://github.com/next-l/enju_inter_library_loan.git'
gem 'enju_inventory', :git => 'git://github.com/next-l/enju_inventory.git'
gem 'enju_event', :git => 'git://github.com/next-l/enju_event.git'
#gem 'enju_news', :git => 'git://github.com/next-l/enju_news.git'
gem 'enju_search_log', :git => 'git://github.com/next-l/enju_search_log.git'
gem 'enju_book_jacket', :git => 'git://github.com/next-l/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/next-l/enju_manifestation_viewer.git'
gem 'enju_export', :git => 'git://github.com/next-l/enju_export.git'

platforms :mri_20 do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'zipruby'
  gem 'kgio'
  gem 'charlock_holmes'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcpostgresql-adapter'
  #gem 'activerecord-jdbcmysql-adapter'
  gem 'rubyzip'
  gem 'trinidad'
end

gem 'exception_notification', '~> 3.0.0'
gem 'state_machine', '~> 1.1.2'
gem 'progress_bar'
gem 'inherited_resources', '~> 1.3'
gem 'strongbox'
gem 'dalli', '~> 2.6'
gem 'sitemap_generator', '~> 3.4'
gem 'ri_cal'
gem 'paper_trail', '~> 2.7'
gem 'RedCloth', '>= 4.2.9'
gem 'devise-encryptable'
#gem 'devise_security_extension'
gem 'addressable'
gem 'paperclip-meta', '~> 0.4.3'
gem 'aws-sdk'
gem 'whenever', :require => false
gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobile-fu'
gem 'geocoder'
gem 'client_side_validations', '~> 3.2'
gem 'simple_form', '~> 2.0'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
#gem 'oink', '>= 0.9.3'
gem 'foreigner'
gem 'strong_parameters'
gem 'resque-scheduler', '~> 2.0.0', :require => 'resque_scheduler'
gem 'acts_as_list'

group :development do
  gem 'annotate', '~> 2.5'
  gem 'sunspot_solr', '~> 2.0.0.pre.130115'
  gem 'rails-erd'
  gem 'immigrant'
end

group :development, :test do
  gem 'simplecov', '~> 0.7', :require => false
#  gem 'ruby-prof', :platforms => :mri_20
  gem 'rspec-rails', '~> 2.12'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 4.1'
  gem 'spork-rails'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/justinko/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.2'
  gem 'fakeweb'
  gem 'steak'
  gem 'resque_spec'
  gem 'parallel_tests', '~> 0.8'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer', '0.10.2', :platform => :ruby
  gem 'therubyrhino', :platform => :jruby

  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
