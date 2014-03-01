class Notifier < ActionMailer::Base
  include Resque::Mailer

  def message_notification(message_id)
    message = Message.find(message_id)
    I18n.locale = message.receiver.locale.try(:to_sym) || I18n.default_locale
    from = "#{LibraryGroup.system_name(message.receiver.locale)} <#{LibraryGroup.site_config.email}>"
    if message.subject
      subject = message.subject
    else
      subject = I18n.t('message.new_message_from_library', :library => LibraryGroup.system_name(message.receiver.user.locale))
    end
    if message.sender
      # TODO 氏名はProfileモデルへ移動
      @sender_name = message.sender.username
    else
      @sender_name = LibraryGroup.system_name(message.receiver.locale)
    end
    @message = message
    @locale = message.receiver.locale
    mail(:from => from, :to => message.receiver.email, :subject => subject)
  end

  def manifestation_info(user_id, manifestation_id)
    user = User.find(user_id)
    manifestation = Manifestation.find(manifestation_id)
    from = "#{LibraryGroup.system_name(user.locale)} <#{LibraryGroup.site_config.email}>"
    subject = "#{manifestation.original_title} : #{LibraryGroup.system_name(user.locale)}"
    @user = user
    @manifestation = manifestation
    mail(:from => from, :to => user.email, :subject => subject)
  end
end
