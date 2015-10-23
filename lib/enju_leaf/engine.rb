require 'kaminari'
require 'devise'
require 'pundit'
require 'acts_as_list'
require 'strip_attributes'
require 'friendly_id'
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
require 'statesman'
require 'browser'
require 'sunspot_rails'
require 'refile/rails'
require 'refile/mini_magick'
require 'bootstrap-sass'
require 'slim-rails'
require 'postrank-uri'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
