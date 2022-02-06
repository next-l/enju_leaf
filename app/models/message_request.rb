class MessageRequest < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: MessageRequestTransition,
    initial_state: MessageRequestStateMachine.initial_state
  ]
  scope :not_sent, -> {in_state(:pending).where('sent_at IS NULL')}
  scope :sent, -> {in_state(:sent)}
  belongs_to :message_template
  belongs_to :sender, class_name: "User", foreign_key: "sender_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_id"
  has_many :messages

  validates :body, presence: { on: :update }

  paginates_per 10

  has_many :message_request_transitions, autosave: false

  def state_machine
    @state_machine ||= MessageRequestStateMachine.new(self, transition_class: MessageRequestTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def send_message
    message = nil
    MessageRequest.transaction do
      message = Message.create!(
        sender: sender,
        recipient: receiver.username,
        subject: subject,
        body: body,
        message_request: self
      )
      update!(sent_at: Time.zone.now)
      if ['reservation_expired_for_patron', 'reservation_expired_for_patron'].include?(message_template.status)
        self.receiver.reserves.each do |reserve|
          reserve.expiration_notice_to_patron = true
          reserve.save(validate: false)
        end
      end
    end

    message
  end

  def subject
    message_template.title
  end

  def save_message_body(options = {})
    options = {
      receiver: receiver,
      locale: receiver.profile.locale
    }.merge(options)
    update!({body: message_template.embed_body(options)})
  end

  def self.send_messages
    count = MessageRequest.not_sent.size
    MessageRequest.not_sent.each do |request|
      request.transition_to!(:sent)
    end
    logger.info "#{Time.zone.now} sent #{count} messages!"
  end
end

# == Schema Information
#
# Table name: message_requests
#
#  id                  :bigint           not null, primary key
#  sender_id           :bigint
#  receiver_id         :bigint
#  message_template_id :bigint
#  sent_at             :datetime
#  body                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
