#require 'enju_biblio'
#require 'enju_library'
require 'enju_seed'
require 'devise'
#require 'enju_manifestation_viewer'
require 'browser'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
#require 'redis-rails'
require 'jquery-ui-rails'
require 'resque/scheduler/server'
require 'bcrypt/password'
require 'elasticsearch/model'
require 'elasticsearch/rails'
if RUBY_PLATFORM == "java"
  require 'kramdown'
else
  require 'redcarpet'
end

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
