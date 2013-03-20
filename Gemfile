source 'https://rubygems.org'

#ruby '2.0.0'
gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_biblio', '~> 0.1.0.pre26'
gem 'enju_library', '~> 0.1.0.pre14'
gem 'enju_flower', '~> 0.1.0.pre2'
#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_barcode', :git => 'git://github.com/nabeta/enju_barcode.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', '~> 0.1.0.pre10'
#gem 'enju_nii', '~> 0.1.0.pre4'
gem 'enju_oai', '~> 0.1.0.pre8'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
#gem 'enju_subject', '~> 0.1.0.pre7'
#gem 'enju_purchase_request', '~> 0.1.0.pre6'
#gem 'enju_question', '~> 0.1.0.pre7'
#gem 'enju_bookmark', '~> 0.1.2.pre8'
#gem 'enju_resource_merge', '~> 0.1.0.pre6'
gem 'enju_circulation', '~> 0.1.0.pre16'
gem 'enju_message', '~> 0.1.4.pre15'
#gem 'enju_inter_library_loan', '~> 0.1.0.pre6'
#gem 'enju_inventory', '~> 0.1.1.pre6'
#gem 'enju_event', '~> 0.1.17.pre7'
#gem 'enju_news', '~> 0.1.0.pre3'
#gem 'enju_search_log', '~> 0.1.0.pre4'
gem 'enju_book_jacket', '~> 0.1.0.pre6'
gem 'enju_manifestation_viewer', '~> 0.1.0.pre4'
#gem 'enju_export', '~> 0.1.1.pre3'

platforms :mri do
  gem 'pg'
  #gem 'mysql2', '~> 0.3'
  #gem 'sqlite3'
  gem 'zipruby'
  gem 'kgio'
  gem 'charlock_holmes'
  gem 'redcarpet'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcpostgresql-adapter'
  #gem 'activerecord-jdbcmysql-adapter'
  gem 'rubyzip'
  gem 'trinidad', :require => false
  #gem 'kramdown'
end

gem 'exception_notification', '~> 3.0'
gem 'state_machine', '~> 1.1.2'
gem 'progress_bar'
gem 'inherited_resources', '~> 1.3'
gem 'strongbox'
gem 'dalli', '~> 2.6'
gem 'sitemap_generator', '~> 3.4'
gem 'paper_trail', '~> 2.7'
gem 'devise-encryptable'
#gem 'devise_security_extension'
gem 'aws-sdk'
gem 'whenever', :require => false
#gem 'astrails-safe'
gem 'dynamic_form'
gem 'sanitize'
gem 'mobylette'
gem 'client_side_validations', '~> 3.2'
gem 'validates_timeliness'
gem 'rack-protection'
gem 'awesome_nested_set', '~> 2.1'
gem 'rails_autolink'
#gem 'oink', '>= 0.10'
gem 'foreigner'
gem 'strong_parameters'
gem 'resque-scheduler', '~> 2.0.0', :require => 'resque_scheduler'
gem 'paperclip-meta'
gem 'redis-rails'

group :development do
  gem 'annotate', '~> 2.5'
  gem 'sunspot_solr', '~> 2.0.0'
  gem 'rails-erd'
  gem 'immigrant'
end

group :development, :test do
  gem 'simplecov', '~> 0.7', :require => false
  gem 'ruby-prof', :platforms => :mri
  gem 'rspec-rails', '~> 2.13'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 4.2'
  gem 'spork-rails'
  gem 'timecop'
  gem 'sunspot-rails-tester', :git => 'git://github.com/justinko/sunspot-rails-tester.git'
  gem 'vcr', '~> 2.4'
  gem 'steak'
  gem 'resque_spec'
  gem 'parallel_tests', '~> 0.9'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-modal-rails'
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
