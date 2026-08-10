class EventImportMailer < ApplicationMailer
  def completed(event_import_file)
    @event_import_file = event_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(event_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('event_import_mailer.completed.subject')}: #{@event_import_file.id}"
    mail(from: from, to: event_import_file.user.email, subject: subject)
  end

  def failed(event_import_file)
    @event_import_file = event_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(event_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('event_import_mailer.failed.subject')}: #{@event_import_file.id}"
    mail(from: from, to: event_import_file.user.email, subject: subject)
  end
end
