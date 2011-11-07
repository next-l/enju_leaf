module UsersHelper
  def enumrate_user_name(family)
    v = ""
    family.users.each do |u|
      v.concat("#{u.patron.full_name if u.patron} (#{u.username}) ")
    end
    return v
  end

  def family_radio_check?(user_id, user, family=nil)
    logger.info "family_radio_check user_id=#{user_id} user=#{user} families=#{family}"

    if user.nil?
      if user_id.to_s == ""
        return true
      else
        return false
      end
    else
      if user_id.to_s == ""
        return false
      else
        if family
          family.users.each do |u|
            logger.info "user.id=#{user.id} u.id=#{u.id}"
            if user.id == u.id
              logger.info "match"
              return true
            end
          end
          return false
        end
        return false
      end
    end
  end
end
