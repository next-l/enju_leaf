class SystemConfiguration < ActiveRecord::Base
  default_scope order('id ASC') 

  after_commit lambda {    
    Rails.cache.clear
  }

  def self.typenames
    ["String","Boolean","Numeric"]
  end

  validates_presence_of :keyname, :v, :typename
  validates_inclusion_of :typename, :in => SystemConfiguration.typenames
  validate :value_by_typename_is_valid

  Prefix_Key = "systemconfig_"

  def self.get(keyname)
    value = typename = nil

    s = Rails.cache.read("#{Prefix_Key}#{keyname}")
    if s
      logger.debug "using cache:#{Prefix_Key}#{keyname}"
    else
      s = SystemConfiguration.where(:keyname => keyname).first rescue nil
      if s
        Rails.cache.write("#{Prefix_Key}#{keyname}", s)
      end
    end
    if s
      value = s.v
      typename = s.typename
    end

    #value = SystemConfiguration.where(:keyname => keyname).first.v rescue nil
    #typename = SystemConfiguration.where(:keyname => keyname).first.typename rescue nil
    if value and typename
      case typename
      when "String"
        return value.to_s
      when "Boolean"
        if value == "true"
          return true
        else
          return false
        end
      when "Numeric"
        return value.to_i
      end
    else
      return eval("configatron.#{keyname}") 
    end
  end

  private  
  def value_by_typename_is_valid
    unless self.v.blank?
      case typename
      when "String"
      when "Boolean"
        unless ["true","false"].include?(v)
          errors.add(:v, I18n.t('activerecord.attributes.system_configuration.invalid_format')) 
        end
      when "Numeric"
        unless v =~ /^[0-9]+$/ 
          errors.add(:v, I18n.t('activerecord.attributes.system_configuration.invalid_format')) 
        end
      end
    end
  end


end
