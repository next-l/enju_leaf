module ExportFile
  extend ActiveSupport::Concern

  included do
    belongs_to :user
    validates :user, presence: true
    attr_accessor :mode
  end

  def send_message
    sender = User.find(1) #system
    locale = user.profile.try(:locale) || I18n.default_locale.to_s
    message_template = MessageTemplate.localized_template('export_completed', locale)
    request = MessageRequest.new
    request.assign_attributes({sender: sender, receiver: user, message_template: message_template})
    request.save_message_body
    request.transition_to!(:sent)
  end
end
