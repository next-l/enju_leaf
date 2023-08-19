class Notifier < ApplicationMailer
  def message_notification(message_id)
    message = Message.find(message_id)
    from = "#{LibraryGroup.system_name(message.receiver.profile.locale)} <#{LibraryGroup.site_config.email}>"
    if message.subject
      subject = message.subject
    else
      subject = I18n.t('message.new_message_from_library', library: LibraryGroup.system_name(message.receiver.user.profile.locale))
    end
    if message.sender
      @sender_name = message.sender.username
    else
      @sender_name = LibraryGroup.system_name(message.receiver.profile.locale)
    end
    @message = message
    @locale = message.receiver.profile.locale
    mail(from: from, to: message.receiver.email, subject: subject)
  end

  def manifestation_info(user_id, manifestation_id)
    user = User.find(user_id)
    manifestation = Manifestation.find(manifestation_id)
    from = "#{LibraryGroup.system_name(user.profile.locale)} <#{LibraryGroup.site_config.email}>"
    subject = "#{manifestation.original_title} : #{LibraryGroup.system_name(user.profile.locale)}"
    @user = user
    @items = Pundit.policy_scope!(user, manifestation.items)
    @manifestation = manifestation
    mail(from: from, to: user.email, subject: subject)
  end
end
