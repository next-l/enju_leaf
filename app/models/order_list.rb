class OrderList < ActiveRecord::Base
  scope :not_ordered, where(:state => 'pending')

  has_many :orders, :dependent => :destroy
  has_many :purchase_requests, :through => :orders
  belongs_to :user, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :subscriptions
  before_save :set_ordered_at

  validates_presence_of :title, :user, :bookstore
  validates_associated :user, :bookstore
  validates_format_of :ordered_at_s, :with => /^\d{4}-\d{2}-\d{2}$|^\d{4}-\d{2}-\d{2} \d{2}:\d{2}/, :allow_blank => true

  attr_accessor :ordered_at_s
  state_machine :initial => :pending do
    before_transition :pending => :ordered, :do => :order

    event :sm_order do
      transition :pending => :ordered
    end
  end

  paginates_per 5
 
  def total_price
    self.purchase_requests.sum(:price)
  end

  def order
    self.ordered_at = Time.zone.now
  end

  def ordered?
    true if self.ordered_at.present?
  end

  def set_ordered_at
    return if ordered_at_s.blank?
    begin
      self.ordered_at = Time.zone.parse("#{ordered_at_s}")
    rescue ArgumentError
    end
  end

end

# == Schema Information
#
# Table name: order_lists
#
#  id           :integer         not null, primary key
#  user_id      :integer         not null
#  bookstore_id :integer         not null
#  title        :text            not null
#  note         :text
#  ordered_at   :datetime
#  deleted_at   :datetime
#  state        :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

