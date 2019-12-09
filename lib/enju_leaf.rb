require "enju_leaf/engine"
require "enju_leaf/version"
require 'csv'
require 'nkf'
require 'ipaddr'

module EnjuLeaf
  if Rails.env == 'test'
    ROOT_PATH = Pathname.new(File.join(__dir__, "../spec/dummy"))
  else
    ROOT_PATH = Pathname.new(File.join(__dir__, ".."))
  end

  class << self
    def webpacker
      @webpacker ||= ::Webpacker::Instance.new(
        root_path: ROOT_PATH,
        config_path: ROOT_PATH.join("config/webpacker.yml")
      )
    end
  end

  class InvalidLocaleError < StandardError
  end
end
