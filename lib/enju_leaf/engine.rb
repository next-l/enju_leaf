require 'enju_seed'
require 'elasticsearch/model'
require 'elasticsearch/rails'
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
require 'statesman'
require 'shrine'
require 'bootstrap-sass'
require 'slim-rails'
#require 'postrank-uri'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
