class ReserveMailer < ApplicationMailer
  def accepted(reserve)
    @library_group = LibraryGroup.site_config
    @reserve = reserve
    system_name = LibraryGroup.system_name(reserve.user.profile.locale)

    from = "#{system_name}] <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('reserve_mailer.accepted')}"
    mail(from: from, to: reserve.user.email, cc: from, subject: subject)
  end

  def canceled(reserve)
    @library_group = LibraryGroup.site_config
    @reserve = reserve
    system_name = LibraryGroup.system_name(reserve.user.profile.locale)

    from = "#{system_name}] <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('reserve_mailer.canceled')}"
    mail(from: from, to: reserve.user.email, cc: from, subject: subject)
  end

  def expired(reserve)
    @library_group = LibraryGroup.site_config
    @reserve = reserve
    system_name = LibraryGroup.system_name(reserve.user.profile.locale)

    from = "#{system_name}] <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('reserve_mailer.expired')}"
    mail(from: from, to: reserve.user.email, cc: from, subject: subject)
  end

  def retained(reserve)
    @library_group = LibraryGroup.site_config
    @reserve = reserve
    system_name = LibraryGroup.system_name(reserve.user.profile.locale)

    from = "#{system_name}] <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('reserve_mailer.retained')}"
    mail(from: from, to: reserve.user.email, cc: from, subject: subject)
  end

  def postponed(reserve)
    @library_group = LibraryGroup.site_config
    @reserve = reserve
    system_name = LibraryGroup.system_name(reserve.user.profile.locale)

    from = "#{system_name}] <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('reserve_mailer.postponed')}"
    mail(from: from, to: reserve.user.email, cc: from, subject: subject)
  end
end
