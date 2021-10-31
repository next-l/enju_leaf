class UserExportMailer < ApplicationMailer
  def completed(user_export_file)
    @user_export_file = user_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(user_export_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('user_export_mailer.completed.subject')}: #{@user_export_file.id}"
    mail(from: from, to: user_export_file.user.email, subject: subject)
  end

  def failed(user_export_file)
    @user_export_file = user_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(user_export_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('user_export_mailer.failed.subject')}: #{@user_export_file.id}"
    mail(from: from, to: user_export_file.user.email, subject: subject)
  end
end
