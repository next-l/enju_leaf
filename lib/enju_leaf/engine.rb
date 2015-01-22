require 'kaminari'
require 'devise'
require 'cancancan'
require 'acts_as_list'
require 'attribute_normalizer'
require 'friendly_id'
require 'addressable/uri'
require 'sunspot_rails'
require 'resque/server'
require 'settingslogic'
require 'nested_form'
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
require 'redcarpet'
require 'mobylette'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
require 'redis-rails'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'statesman'
require 'resque/scheduler/server'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
