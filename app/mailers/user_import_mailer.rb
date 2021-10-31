class UserImportMailer < ApplicationMailer
  def completed(user_import_file)
    @user_import_file = user_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(user_import_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('user_import_mailer.completed.subject')}: #{@user_import_file.id}"
    mail(from: from, to: user_import_file.user.email, subject: subject)
  end

  def failed(user_import_file)
    @user_import_file = user_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(user_import_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('user_import_mailer.failed.subject')}: #{@user_import_file.id}"
    mail(from: from, to: user_import_file.user.email, subject: subject)
  end
end
