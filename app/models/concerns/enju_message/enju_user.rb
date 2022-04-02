module EnjuMessage
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :sent_messages, foreign_key: 'sender_id', class_name: 'Message', inverse_of: :sender
      has_many :received_messages, foreign_key: 'receiver_id', class_name: 'Message', inverse_of: :receiver
    end

    def send_message(status, options = {})
      MessageRequest.transaction do
        request = MessageRequest.new
        request.sender = self.class.find(1)
        request.receiver = self
        request.message_template = MessageTemplate.localized_template(status, profile.locale)
        request.save_message_body(options)
        request.transition_to!(:sent)
      end
    end
  end
end
