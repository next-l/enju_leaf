source 'https://rubygems.org'

#ruby '2.0.0'
gem 'rails', '3.2.15'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'enju_leaf', '~> 1.1.0.rc7'
gem "enju_flower", "~> 0.1.0.pre13"
gem "enju_ndl", "~> 0.1.0.pre27"
gem "enju_circulation", "~> 0.1.0.pre30"
gem "enju_subject", "~> 0.1.0.pre21"

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

gem 'exception_notification', '~> 4.0'
gem 'progress_bar'
gem 'strongbox'
#gem 'devise_security_extension'
gem 'whenever', :require => false
#gem 'astrails-safe'
gem 'sanitize'
gem 'rack-protection'
gem 'rails_autolink'
#gem 'oink', '>= 0.10'
gem 'foreigner'
gem 'strong_parameters'
gem 'resque-scheduler', '~> 2.0', :require => 'resque_scheduler'
gem 'redis-rails'

group :development do
  gem 'annotate', '~> 2.5'
  gem 'sunspot_solr', '~> 2.1'
  gem 'rails-erd'
  gem 'immigrant'
end

group :development, :test do
  gem 'simplecov', '~> 0.8', :require => false
  gem 'ruby-prof', :platforms => :mri
  gem 'rspec-rails', '~> 2.13'
  gem 'guard-rspec'
  gem 'factory_girl_rails', '~> 4.3'
  gem 'spork-rails'
  gem 'timecop'
  gem 'sunspot-rails-tester'
  gem 'vcr', '~> 2.7'
  gem 'fakeweb'
  gem 'steak'
  gem 'resque_spec'
  gem 'parallel_tests', '~> 0.16'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', '0.10.2', :platform => :ruby
  # gem 'therubyrhino', :platform => :jruby

  gem 'uglifier', '>= 1.0.3'
  gem 'less-rails'
  gem 'twitter-bootstrap-rails'
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
