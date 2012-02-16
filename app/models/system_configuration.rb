class SystemConfiguration < ActiveRecord::Base
  default_scope order('id ASC') 

  def self.typenames
    ["String","Boolean","Numeric"]
  end

  validates_presence_of :keyname, :v, :typename
  validates_inclusion_of :typename, :in => SystemConfiguration.typenames
  validate :value_by_typename_is_valid

  def self.get(keyname)
    value = SystemConfiguration.where(:keyname => keyname).first.v rescue nil
    typename = SystemConfiguration.where(:keyname => keyname).first.typename rescue nil
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
    logger.info "aaaa"
    unless self.v.blank?
      case typename
      when "String"
      when "Boolean"
        logger.info "bbb"
        unless ["true","false"].include?(v)
          errors.add(:v, I18n.t('activerecord.attributes.system_configuration.invalid_format')) 
        end
      when "Numeric"
        unless v =~ /^[0-9]+$/ 
          errors[:base] << I18n.t('activerecord.attributes.system_configuration.invalid_format')
        end
      end
    end
  end


end
