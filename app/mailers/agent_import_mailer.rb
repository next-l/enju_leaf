class AgentImportMailer < ApplicationMailer
  def completed(agent_import_file)
    @agent_import_file = agent_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(agent_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('agent_import_mailer.completed.subject')}: #{@agent_import_file.id}"
    mail(from: from, to: agent_import_file.user.email, subject: subject)
  end

  def failed(agent_import_file)
    @agent_import_file = agent_import_file
    @library_group = LibraryGroup.site_config
    from = "#{LibraryGroup.system_name(agent_import_file.user.profile.locale)} <#{@library_group.email}>"
    subject = "#{I18n.t('agent_import_mailer.failed.subject')}: #{@agent_import_file.id}"
    mail(from: from, to: agent_import_file.user.email, subject: subject)
  end
end
