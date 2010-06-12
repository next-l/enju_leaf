class Checkout < ActiveRecord::Base
  default_scope :order => 'id DESC'
  scope :not_returned, :conditions => ['checkin_id IS NULL']
  scope :overdue, lambda {|date| {:conditions => ['checkin_id IS NULL AND due_date < ?', date]}}
  scope :due_date_on, lambda {|date| {:conditions => ['checkin_id IS NULL AND due_date = ?', date]}}
  scope :completed, lambda {|start_date, end_date| {:conditions => ['created_at >= ? AND created_at < ?', start_date, end_date]}}
  
  belongs_to :user #, :counter_cache => true #, :validate => true
  belongs_to :item #, :counter_cache => true #, :validate => true
  belongs_to :checkin #, :validate => true
  belongs_to :librarian, :class_name => 'User' #, :validate => true
  belongs_to :basket #, :validate => true

  validates_associated :user, :item, :librarian, :checkin #, :basket
  # TODO: 貸出履歴を保存しない場合は、ユーザ名を削除する
  #validates_presence_of :user, :item, :basket
  validates_presence_of :item_id, :basket_id
  validates_uniqueness_of :item_id, :scope => [:basket_id, :user_id]
  validate :is_not_checked?, :on => :create

  def self.per_page
    10
  end

  def is_not_checked?
    checkout = Checkout.not_returned.find(self.item) rescue nil
    unless checkout.nil?
      errors[:base] << I18n.t('activerecord.errors.messages.checkin.already_checked_out')
    end
  end

  def checkout_renewable?
    return false if self.overdue?
    if self.item
      return false if self.over_checkout_renewal_limit?
      return false if self.reserved?
    end
    true
  end

  def reserved?
    return true if self.item.reserved?
  end

  def over_checkout_renewal_limit?
    return true if self.item.checkout_status(self.user).checkout_renewal_limit <= self.checkout_renewal_count
  end

  def overdue?
    if Time.zone.now.tomorrow.beginning_of_day > self.due_date
      return true
    else
      return false
    end
  end

  def is_today_due_date?
    if Time.zone.now.beginning_of_day == self.due_date.beginning_of_day
      return true
    else
      return false
    end
  end

  def set_renew_due_date(user)
    if self.item
      if self.checkout_renewal_count <= self.item.checkout_status(user).checkout_renewal_limit
        renew_due_date = self.due_date.advance(:days => self.item.checkout_status(user).checkout_period)
      else
        renew_due_date = self.due_date
      end
    end
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    self.completed(start_date, end_date).count(:all, :conditions => {:item_id => manifestation.items.collect(&:id)})
  end

  def self.send_due_date_notification(day = 1)
    template = 'recall_item'
    User.find_each do |user|
      # 未来の日時を指定する
      checkouts = user.checkouts.due_date_on(day.days.from_now.beginning_of_day)
      unless checkouts.empty?
        user.send_message(template, :manifestations => checkouts.collect(&:item).collect(&:manifestation))
      end
    end
  end

  def self.send_overdue_notification(notification_duration = 1, number = 1)
    template = 'recall_overdue_item'
    queues = []
    number.times do |i|
      User.find_each do |user|
        checkouts = user.checkouts.due_date_on((notification_duration * (i + 1)).days.ago.beginning_of_day)
        unless checkouts.empty?
          queues << user.send_message(template, :manifestations => checkouts.collect(&:item).collect(&:manifestation))
        end
      end
    end
    queues.size
  end

end
