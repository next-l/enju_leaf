# -*- coding: utf-8 -*-
module NotificationSound
  def error_message_and_sound(attribute_symbol)
    msg = t(attribute_symbol) 
    soundfile = nil
    if SystemConfiguration.get("sounds.basedir")
      basedir = SystemConfiguration.get("sounds.basedir")
      soundfile = SystemConfiguration.get("sounds.errors.#{attribute_symbol}") 
      if soundfile.blank?
        soundpath = basedir + SystemConfiguration.get("sounds.errors.default")
      else
        soundpath = basedir + soundfile
      end
    end
    return [msg, soundpath]
  end
end

