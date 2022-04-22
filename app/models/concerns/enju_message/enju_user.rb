module EnjuMessage
  module EnjuUser
    extend ActiveSupport::Concern

    included do
      has_many :sent_messages, foreign_key: 'sender_id', class_name: 'Message', inverse_of: :sender
      has_many :received_messages, foreign_key: 'receiver_id', class_name: 'Message', inverse_of: :receiver
    end
  end
end
