class Message < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: MessageTransition,
    initial_state: MessageStateMachine.initial_state
  ]
  scope :unread, -> { in_state("unread") }
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  validates :subject, :body, presence: true # , :sender
  validates :receiver, presence: { message: :invalid }
  before_validation :set_receiver
  after_create :send_notification
  after_create :set_default_state
  after_destroy :remove_from_index
  after_save :index!

  acts_as_nested_set
  attr_accessor :recipient

  validates :recipient, presence: true, on: :create

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  searchable do
    text :body, :subject
    string :subject
    integer :receiver_id
    integer :sender_id
    time :created_at
    boolean :is_read do
      read?
    end
  end

  paginates_per 10
  has_many :message_transitions, autosave: false, dependent: :destroy

  def state_machine
    @state_machine ||= MessageStateMachine.new(self, transition_class: MessageTransition)
  end

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def set_receiver
    if recipient
      self.receiver = User.find_by(username: recipient)
    end
  end

  def send_notification
    Notifier.message_notification(id).deliver_later if receiver.try(:email).present?
  end

  def read
    transition_to!(:read)
  end

  def read?
    return true if current_state == "read"

    false
  end

  private

  def set_default_state
    transition_to!(:unread)
  end
end

# == Schema Information
#
# Table name: messages
#
#  id                 :bigint           not null, primary key
#  body               :text
#  depth              :integer
#  lft                :integer
#  read_at            :datetime
#  rgt                :integer
#  subject            :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  message_request_id :bigint
#  parent_id          :bigint
#  receiver_id        :bigint
#  sender_id          :bigint
#
# Indexes
#
#  index_messages_on_message_request_id  (message_request_id)
#  index_messages_on_parent_id           (parent_id)
#  index_messages_on_receiver_id         (receiver_id)
#  index_messages_on_sender_id           (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => messages.id)
#
