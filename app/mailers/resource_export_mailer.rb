class ResourceExportMailer < ApplicationMailer
  def completed(resource_export_file)
    @resource_export_file = resource_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(resource_export_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('resource_export_mailer.completed.subject')}: #{@resource_export_file.id}"
    mail(from: from, to: resource_export_file.user.email, subject: subject)
  end

  def failed(resource_export_file)
    @resource_export_file = resource_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(resource_export_file.user.profile.locale)} <#{@library_group.user.email}>"
    subject = "#{I18n.t('resource_export_mailer.failed.subject')}: #{@resource_export_file.id}"
    mail(from: from, to: resource_export_file.user.email, subject: subject)
  end
end
