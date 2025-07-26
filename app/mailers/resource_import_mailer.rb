class ResourceImportMailer < ApplicationMailer
  def completed(resource_import_file)
    @resource_import_file = resource_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(resource_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('resource_import_mailer.completed.subject')}: #{@resource_import_file.id}"
    mail(from: from, to: resource_import_file.user.email, subject: subject)
  end

  def failed(resource_import_file)
    @resource_import_file = resource_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(resource_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('resource_import_mailer.failed.subject')}: #{@resource_import_file.id}"
    mail(from: from, to: resource_import_file.user.email, subject: subject)
  end
end
