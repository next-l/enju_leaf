class SystemConfiguration < ActiveRecord::Base
  default_scope order('id ASC') 
  validate :value_by_typename_is_valid
  validate :check_length

  after_commit lambda {    
    Rails.cache.clear
  }

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

    if value and typename
      case typename
      when "Text"
        return value.to_s
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
      begin
        v = eval("Setting.#{keyname}") 
      rescue
        logger.warn "key not found: #{keyname}"
      end
      return v
    end
  end

  def self.isWebOPAC
    return true if ENV['ENJU_WEB_OPAC'] or !SystemConfiguration.get('internal_server')
    false
  end

  private  
  def value_by_typename_is_valid
    case typename
    when "Text"
    when "String"
    when "Boolean"
      unless ["true","false"].include?(v)
        errors.add(:v, I18n.t('activerecord.attributes.system_configuration.invalid_format')) 
      end
    when "Numeric"
      unless self.v.blank?
        unless v =~ /^[0-9]+$/ 
          errors.add(:v, I18n.t('activerecord.attributes.system_configuration.invalid_format')) 
        end
      else
        self.v = 0
      end
    end
  end

  def check_length
    case keyname
    when 'checkouts_print.message'
      if v.length > 152
        errors[:base] = I18n.t('system_configuration.error.over_checkouts_print_message', :num => 76)
      end
    when 'reminder_postal_card_message'
      if v.length > 484
        errors[:base] = I18n.t('system_configuration.error.over_reminder_postal_card_message', :num => 242)
      end 
    when 'reminder_letter_message'
      if v.length > 1100
        errors[:base] = I18n.t('system_configuration.error.over_reminder_letter_message', :num => 550)
      end
    end
  end
end
