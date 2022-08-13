class ManifestationReserveStatMailer < ApplicationMailer
  def completed(stat)
    @library_group = LibraryGroup.site_config
    @stat = stat
    system_name = LibraryGroup.system_name(stat.user.profile.locale)

    from = "#{system_name} <#{@library_group.email}>"
    subject = "[#{system_name}] #{I18n.t('manifestation_reserve_stat_mailer.completed', locale: stat.user.profile.locale)}"
    mail(from: from, to: stat.user.email, cc: from, subject: subject)
  end
end
