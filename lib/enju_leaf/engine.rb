require 'kaminari'
require 'devise'
require 'cancancan'
require 'acts_as_list'
require 'normalizr'
require 'friendly_id'
require 'addressable/uri'
require 'elasticsearch/model'
require 'elasticsearch/rails'
require 'nested_form'
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
require 'redcarpet'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
require 'redis-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'statesman'
require 'browser'
require 'sunspot_rails'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
