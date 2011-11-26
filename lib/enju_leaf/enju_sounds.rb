# -*- coding: utf-8 -*-
module ActiveModel
  class Errors
    attr_reader :soundfiles

    def initialize(base)
      @soundfiles = []
      @base = base
      super()
    end
    def add_with_sound(attribute, message, soundfile, options = {})
      @soundfiles << soundfile
      add(attribute, message, options)
    end
  end
end

module EnjuLeaf
  module NotificationSound
    
    def error_message_and_sound(attribute_symbol)
      msg = t(attribute_symbol) 
      soundfile = nil
      if configatron.sounds.basedir
        soundfile = eval("configatron.sounds.errors.#{attribute_symbol}") 
        soundfile = configatron.sounds.basedir + soundfile unless soundfile.inspect.empty?
      end
      return [msg, soundfile]
    end
  end
end

