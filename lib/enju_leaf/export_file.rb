module ExportFile
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def enju_export_file_model
      include InstanceMethods
      belongs_to :user
      validates :user, presence: true
      attr_accessible :mode
      attr_accessor :mode
    end
  end

  module InstanceMethods
    def send_message
      sender = User.find(1)
      message_template = MessageTemplate.localized_template('export_completed', user.profile.locale)
      request = MessageRequest.new
      request.assign_attributes({:sender => sender, :receiver => user, :message_template => message_template}, as: :admin)
      request.save_message_body
      request.transition_to!(:sent)
    end
  end
end
