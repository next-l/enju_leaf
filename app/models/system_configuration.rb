class SystemConfiguration < ActiveRecord::Base
  validates_presence_of :keyname, :v, :typename

  def self.typenames
    ["String","Boolean","Numeric"]
  end

  validates_inclusion_of :typename, :in => SystemConfiguration.typenames

  def self.get(keyname)
    value = SystemConfiguration.where(:keyname => keyname).first.v rescue nil
    if value
      return value
    else
      return eval("configatron.#{keyname}") 
    end
  end
end
