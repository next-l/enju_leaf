require 'enju_biblio'
require 'enju_library'
require 'enju_book_jacket'
require 'enju_manifestation_viewer'
require 'redcarpet'
require 'mobylette'
require 'jquery-ui-rails'
require 'jquery-modal-rails'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
