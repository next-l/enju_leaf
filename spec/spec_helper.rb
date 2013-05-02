require 'simplecov'
SimpleCov.start 'rails' do
  add_filter do |source_file|
    source_file.lines.count < 5
  end
end

require 'rubygems'
require 'vcr'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
# == Mock Framework
#
# If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
#
# config.mock_with :mocha
# config.mock_with :flexmock
# config.mock_with :rr
  config.mock_with :rspec

# Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

# If you're not using ActiveRecord, or you'd prefer not to run each of your
# examples within a transaction, remove the following line or assign false
# instead of true.
  config.use_transactional_fixtures = true

  $original_sunspot_session = Sunspot.session

  config.before do
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new($original_sunspot_session)
    SimpleCov.command_name "RSpec:#{Process.pid.to_s}#{ENV['TEST_ENV_NUMBER']}"
    PaperTrail.controller_info = {}
    PaperTrail.whodunnit = nil
  end

  config.before :each, :solr => true do
    Sunspot::Rails::Tester.start_original_sunspot_session
    Sunspot.session = $original_sunspot_session
    #Sunspot.remove_all!
  end

  config.extend ControllerMacros, :type => :controller
end
