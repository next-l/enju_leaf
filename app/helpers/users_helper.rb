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

  def i18n_telephone_type(type)
    case type
    when 1
      t('activerecord.attributes.patron.home_phone')
    when 2
      t('activerecord.attributes.patron.fax')
    when 3
      t('activerecord.attributes.patron.mobile_phone')
    when 4
      t('activerecord.attributes.patron.company_phone')
    when 5
      t('activerecord.attributes.patron.extension')
    end
  end

  def telephone_types
    types = {}
    types.store(t('activerecord.attributes.patron.extension'), 5)
    types.store(t('activerecord.attributes.patron.home_phone'), 1)
    types.store(t('activerecord.attributes.patron.fax'),  2)
    types.store(t('activerecord.attributes.patron.mobile_phone'), 3)
    types.store(t('activerecord.attributes.patron.company_phone'), 4)
    types
  end

  def library_facet(library, current_libraries, facet)
    string = ''
    current = true if current_libraries.include?(library.name)
    string << "<strong>" if current
    string << link_to("#{library.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :library => (current_libraries << library.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def role_facet(role, current_roles, facet)
    string = ''
    current = true if current_roles.include?(role.name)
    string << "<strong>" if current
    string << link_to("#{role.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :role => (current_roles << role.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def patron_type_facet(patron_type, current_patron_type, facet)
    string = ''
    current = true if current_patron_type.include?(patron_type.name)
    string << "<strong>" if current
    string << link_to("#{patron_type.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :patron_type => (current_patron_type << patron_type.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end

  def user_status_facet(user_status, current_user_statuses, facet)
    string = ''
    current = true if current_user_statuses.include?(user_status.name)
    string << "<strong>" if current
    string << link_to("#{user_status.display_name.localize} (" + facet.count.to_s + ")", url_for(params.merge(:page => nil, :user_status => (current_user_statuses << user_status.name).uniq.join(' '), :view => nil)))
    string << "</strong>" if current
    string.html_safe
  end
end
