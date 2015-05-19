require 'kaminari'
require 'devise'
require 'pundit'
require 'acts_as_list'
require 'strip_attributes'
require 'friendly_id'
require 'addressable/uri'
require 'elasticsearch/model'
require 'elasticsearch/rails'
require 'cocoon'
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
require 'kramdown'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
require 'redis-rails'
require 'jquery-rails'
require 'statesman'
require 'browser'
require 'sunspot_rails'
require 'mini_magick'
require 'refile/rails'
require 'refile/image_processing'
require 'bootstrap-sass'
require 'slim-rails'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
