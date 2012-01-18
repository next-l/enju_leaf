class SystemConfiguration < ActiveRecord::Base
  def self.get(keyname)
    value = SystemConfiguration.where(:keyname => keyname).first.v rescue nil
    if value
      return value
    else
      return eval("configatron.#{keyname}") 
    end
  end
end
