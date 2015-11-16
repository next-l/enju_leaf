require 'kaminari'
require 'devise'
require 'pundit'
require 'acts_as_list'
require 'strip_attributes'
require 'friendly_id'
require 'addressable/uri'
require 'sunspot_rails'
require 'cocoon'
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
require 'kramdown'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
require 'jquery-ui-rails'
require 'statesman'
require 'browser'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
