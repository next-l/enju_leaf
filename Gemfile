source 'https://rubygems.org'

#ruby '2.0.0'
gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_leaf', :git => 'git://github.com/nabeta/enju_leaf.git', :branch => 'gem'
gem 'enju_flower', :git => 'git://github.com/next-l/enju_flower.git'
#gem 'enju_amazon', :git => 'git://github.com/nabeta/enju_amazon.git'
#gem 'enju_barcode', :git => 'git://github.com/nabeta/enju_barcode.git'
#gem 'enju_calil', :git => 'git://github.com/nabeta/enju_calil.git'
gem 'enju_ndl', :git => 'git://github.com/next-l/enju_ndl.git'
#gem 'enju_nii', :git => 'git://github.com/next-l/enju_nii.git'
gem 'enju_oai', :git => 'git://github.com/next-l/enju_oai.git'
#gem 'enju_scribd', :git => 'git://github.com/nabeta/enju_scribd.git'
gem 'enju_subject', :git => 'git://github.com/next-l/enju_subject.git'
#gem 'enju_purchase_request', :git => 'git://github.com/next-l/enju_purchase_request.git'
#gem 'enju_question', :git => 'git://github.com/next-l/enju_question.git'
#gem 'enju_bookmark', :git => 'git://github.com/next-l/enju_bookmark.git'
#gem 'enju_resource_merge', :git => 'git://github.com/next-l/enju_resource_merge.git'
gem 'enju_circulation', :git => 'git://github.com/next-l/enju_circulation.git'
gem 'enju_message', :git => 'git://github.com/next-l/enju_message.git'
#gem 'enju_inter_library_loan', :git => 'git://github.com/next-l/enju_inter_library_loan.git'
#gem 'enju_inventory', :git => 'git://github.com/next-l/enju_inventory.git'
gem 'enju_event', :git => 'git://github.com/next-l/enju_event.git'
#gem 'enju_news', :git => 'git://github.com/next-l/enju_news.git'
#gem 'enju_search_log', :git => 'git://github.com/next-l/enju_search_log.git'
gem 'enju_book_jacket', :git => 'git://github.com/next-l/enju_book_jacket.git'
gem 'enju_manifestation_viewer', :git => 'git://github.com/next-l/enju_manifestation_viewer.git'
gem 'enju_export', :git => 'git://github.com/next-l/enju_export.git'

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

gem 'progress_bar'
gem 'strongbox'
#gem 'devise_security_extension'
#gem 'astrails-safe'
gem 'sanitize'
#gem 'oink', '>= 0.10'
gem 'foreigner'
gem 'strong_parameters'

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
  gem 'parallel_tests', '~> 0.10'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-modal-rails'

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
