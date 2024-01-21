require_relative "boot"

require "rails/all"
require 'csv'
require 'nkf'
require 'rss'
require_relative '../lib/enju_leaf/version'
require_relative '../lib/openurl

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnjuLeaf
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    default_locale = (ENV['ENJU_LEAF_DEFAULT_LOCALE'] || 'en').to_sym
    config.i18n.default_locale = default_locale
    config.i18n.available_locales = [default_locale, :ja, :en].uniq
    config.time_zone = ENV['ENJU_LEAF_TIME_ZONE'] || 'UTC'

    base_url = URI.parse(ENV['ENJU_LEAF_BASE_URL'] || 'http://localhost:8080')
    config.action_mailer.default_url_options = {
      host: base_url.host,
      protocol: base_url.scheme,
      port: base_url.port
    }
  end
end
