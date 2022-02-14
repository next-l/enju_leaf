class Message < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: MessageTransition,
    initial_state: MessageStateMachine.initial_state
  ]
  scope :unread, -> {in_state('unread')}
  belongs_to :message_request, optional: true
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  validates :subject, :body, presence: true # , :sender
  validates :receiver, presence: { message: :invalid }
  before_validation :set_receiver
  after_save :index
  after_destroy :remove_from_index
  after_create :send_notification

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
  has_many :message_transitions, autosave: false
  after_create :set_default_state

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
    return true if current_state == 'read'

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
#  read_at            :datetime
#  sender_id          :bigint
#  receiver_id        :bigint
#  subject            :string           not null
#  body               :text
#  message_request_id :bigint
#  parent_id          :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  lft                :integer
#  rgt                :integer
#  depth              :integer
#
