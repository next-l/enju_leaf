class Notifier < ActionMailer::Base
  if LibraryGroup.site_config.try(:url)
    uri = Addressable::URI.parse(LibraryGroup.site_config.url)
    default_url_options[:host] = uri.host
    default_url_options[:port] = uri.port if configatron.enju.web_port_number != 80
  else
    default_url_options[:host] = configatron.enju.web_hostname
    default_url_options[:port] = configatron.enju.web_port_number if configatron.enju.web_port_number != 80
  end

  def message_notification(message)
    I18n.locale = message.receiver.locale.to_sym
    from = "#{LibraryGroup.system_name(message.receiver.locale)} <#{LibraryGroup.site_config.email}>"
    if message.subject
      subject = message.subject
    else
      subject = I18n.t('message.new_message_from_library', :library => LibraryGroup.system_name(message.receiver.user.locale))
    end
    if message.sender
      @sender_name = message.sender.patron.full_name
    else
      @sender_name = LibraryGroup.system_name(message.receiver.locale)
    end
    @message = message
    @locale = message.receiver.locale
    mail(:from => from, :to => message.receiver.email, :subject => subject)
  end

  def manifestation_info(user, manifestation)
    from = "#{LibraryGroup.system_name(user.locale)} <#{LibraryGroup.site_config.email}>"
    subject = "#{manifestation.original_title} : #{LibraryGroup.system_name(user.locale)}"
    @user = user
    @manifestation = manifestation
    mail(:from => from, :to => user.email, :subject => subject)
  end
end
