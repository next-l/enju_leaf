class EventExportMailer < ApplicationMailer
  def completed(event_export_file)
    @event_export_file = event_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(event_export_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('event_export_mailer.completed.subject')}: #{@event_export_file.id}"
    mail(from: from, to: event_export_file.user.email, subject: subject)
  end

  def failed(event_export_file)
    @event_export_file = event_export_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(event_export_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('event_export_mailer.failed.subject')}: #{@event_export_file.id}"
    mail(from: from, to: event_export_file.user.email, subject: subject)
  end
end
