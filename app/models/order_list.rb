class OrderList < ApplicationRecord
  include Statesman::Adapters::ActiveRecordQueries[
    transition_class: OrderListTransition,
    initial_state: :pending
  ]
  scope :not_ordered, -> { in_state(:not_ordered) }

  has_many :orders, dependent: :destroy
  has_many :purchase_requests, through: :orders
  belongs_to :user, validate: true
  belongs_to :bookstore, validate: true
  has_many :subscriptions

  after_create do
    transition_to(:not_ordered)
  end

  validates_presence_of :title, :user, :bookstore
  validates_associated :user, :bookstore

  attr_accessor :edit_mode

  paginates_per 10

  def state_machine
    OrderListStateMachine.new(self, transition_class: OrderListTransition)
  end

  has_many :order_list_transitions, autosave: false

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state,
    to: :state_machine

  def total_price
    purchase_requests.sum(:price)
  end

  def order
    self.ordered_at = Time.zone.now
  end

  def ordered?
    true if current_state == "ordered"
  end
end

# == Schema Information
#
# Table name: order_lists
#
#  id           :bigint           not null, primary key
#  note         :text
#  ordered_at   :datetime
#  title        :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bookstore_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_order_lists_on_bookstore_id  (bookstore_id)
#  index_order_lists_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (bookstore_id => bookstores.id)
#  fk_rails_...  (user_id => users.id)
#
