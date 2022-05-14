require_relative 'boot'

require 'rails/all'
require 'csv'
require 'nkf'
require 'rss'
require_relative '../lib/enju_leaf/version'
require_relative '../lib/openurl'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EnjuLeaf
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.i18n.default_locale = (ENV['ENJU_LEAF_DEFAULT_LOCALE'] || 'en').to_sym
    config.time_zone = ENV['ENJU_LEAF_TIME_ZONE'] || 'UTC'
  end
end
