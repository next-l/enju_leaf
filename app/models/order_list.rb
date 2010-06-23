class OrderList < ActiveRecord::Base
  scope :not_ordered, :conditions => ['state = ?', 'pending']

  has_many :orders, :dependent => :destroy
  has_many :purchase_requests, :through => :orders
  belongs_to :user, :validate => true
  belongs_to :bookstore, :validate => true
  has_many :subscriptions

  validates_presence_of :title, :user, :bookstore
  validates_associated :user, :bookstore

  state_machine :initial => :pending do
    before_transition :pending => :ordered, :do => :order

    event :sm_order do
      transition :pending => :ordered
    end
  end

  def self.per_page
    10
  end

  def total_price
    self.purchase_requests.sum(:price)
  end

  def order
    self.ordered_at = Time.zone.now
  end

  def ordered?
    true if self.ordered_at.present?
  end
end
