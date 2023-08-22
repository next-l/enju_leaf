require 'capybara/rspec'
require "selenium-webdriver"

Capybara.register_driver :remote_chrome do |app|
  url = ENV['SELENIUM_DRIVER_URL']

  options = ::Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless")
  options.add_argument("--no-sandbox")
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :remote, url: url, options: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    Capybara.server_host = IPSocket.getaddress(Socket.gethostname)
    Capybara.app_host = "http://#{Capybara.server_host}"
    driven_by :remote_chrome
  end
end
