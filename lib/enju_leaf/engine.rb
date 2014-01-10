<<<<<<< HEAD
require 'enju_biblio'
require 'enju_library'
require 'enju_manifestation_viewer'
=======
#require 'enju_biblio'
#require 'enju_library'
require 'enju_core'
require 'devise'
#require 'enju_manifestation_viewer'
>>>>>>> 29dbd91... added UserImportFile and UserImportResult
require 'redcarpet'
require 'mobylette'
require 'rails_autolink'
require 'devise-encryptable'
require 'sitemap_generator'
require 'redis-rails'
require 'jquery-rails'
require 'jquery-ui-rails'

module EnjuLeaf
  class Engine < ::Rails::Engine
    initializer :assets do |config|
      Rails.application.config.assets.precompile += %w( mobile.js mobile.css print.css )
    end
  end
end
