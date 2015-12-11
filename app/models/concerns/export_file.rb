module ExportFile
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_export_file_model
      include InstanceMethods
      belongs_to :user
      validates :user, presence: true
      attr_accessor :mode
    end
  end

  module InstanceMethods
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
end
