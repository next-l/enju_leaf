module UsersHelper
  def enumrate_user_name(family)
    v = ""
    family.users.each do |u|
      v.concat("#{u.patron.full_name if u.patron} (#{u.username}) ")
    end
    return v
  end

  def family_radio_check?(btn_value, family)
    #logger.info "family_radio_check v=[#{btn_value}] f=[#{family}]"
    #logger.info "family_radio_check v=[#{btn_value.class}] f=[#{family.class}]"
    if family.empty? && btn_value == 0
      return true
    end
    if btn_value.to_s == family
      #logger.info "true"
      return true
    end
    #logger.info "false"
    return false
  end
end
