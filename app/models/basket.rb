class Basket < ActiveRecord::Base
  attr_accessible :note, :user_number
  default_scope :order => 'baskets.id DESC'
  scope :will_expire, lambda {|date| {:conditions => ['created_at < ?', date]}}
  belongs_to :user, :validate => true
  has_many :accepts

  validates_associated :user, :on => :create
  # 貸出完了後にかごのユーザidは破棄する
  validates_presence_of :user, :on => :create
  validate :check_suspended

  attr_accessor :user_number

  def check_suspended
    if self.user
      errors[:base] << I18n.t('basket.this_account_is_suspended') if self.user.locked_at?
    else
      errors[:base] << I18n.t('user.not_found')
    end
  end

  def self.expire
    Basket.will_expire(Time.zone.now.beginning_of_day).destroy_all
    logger.info "#{Time.zone.now} baskets expired!"
  end

  if defined?(EnjuCirculation)
    has_many :checked_items, :dependent => :destroy
    has_many :items, :through => :checked_items
    has_many :checkouts
    has_many :checkins

    def basket_checkout(librarian)
      return nil if checked_items.size == 0
      Item.transaction do
        self.checked_items.each do |checked_item|
          checkout = self.user.checkouts.new
          checkout.librarian = librarian
          checkout.item = checked_item.item
          checkout.basket = self
          checkout.due_date = checked_item.due_date
          checked_item.item.checkout!(user)
          checkout.save!
        end
        CheckedItem.destroy_all(:basket_id => id)
      end
    end
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :integer         not null, primary key
#  user_id      :integer
#  note         :text
#  lock_version :integer         default(0), not null
#  created_at   :datetime        not null
#  updated_at   :datetime        not null
#

