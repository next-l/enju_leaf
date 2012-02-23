# -*- coding: utf-8 -*-
module ActiveModel
  class Errors
    attr_reader :soundfiles

    def initialize(base)
      @soundfiles = []
      @base = base
      @messages = ActiveSupport::OrderedHash.new
    end

    def add_with_sound(attribute, message, soundfile, options = {})
      @soundfiles << soundfile
      add(attribute, message, options)
    end
  end
end

module NotificationSound
  def error_message_and_sound(attribute_symbol)
    msg = t(attribute_symbol) 
    soundfile = nil
    if SystemConfiguration.get("sounds.basedir")
      soundfile = SystemConfiguration.get("sounds.errors.#{attribute_symbol}") 
      soundfile = SystemConfiguration.get("sounds.basedir") + soundfile unless soundfile.inspect.empty?
    end
    return [msg, soundfile]
  end
end

