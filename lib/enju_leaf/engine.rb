require 'enju_biblio'
require 'enju_library'
require 'jquery-ui-rails'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( enju_leaf/mobile.js enju_leaf/mobile.css enju_leaf/print.css )
    end
  end
end
