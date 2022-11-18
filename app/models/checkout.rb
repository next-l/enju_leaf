class Checkout < ApplicationRecord
  scope :not_returned, -> { where(checkin_id: nil) }
  scope :returned, -> { where.not(checkin_id: nil) }
  scope :overdue, lambda {|date| where('checkin_id IS NULL AND due_date < ?', date)}
  scope :due_date_on, lambda {|date| where(checkin_id: nil, due_date: date.beginning_of_day .. date.end_of_day)}
  scope :completed, lambda {|start_date, end_date| where('checkouts.created_at >= ? AND checkouts.created_at < ?', start_date, end_date)}
  scope :on, lambda {|date| where('created_at >= ? AND created_at < ?', date.beginning_of_day, date.tomorrow.beginning_of_day)}

  belongs_to :user, optional: true
  delegate :username, :user_number, to: :user, prefix: true
  belongs_to :item, touch: true
  belongs_to :checkin, optional: true
  belongs_to :librarian, class_name: 'User'
  belongs_to :basket
  belongs_to :shelf, optional: true
  belongs_to :library, optional: true

  # TODO: 貸出履歴を保存しない場合は、ユーザ名を削除する
  # validates :user, :item, :basket, presence: true
  validates :due_date, date: true, presence: true
  validates :item_id, uniqueness: { scope: [:basket_id, :user_id] }
  validate :is_not_checked?, on: :create
  validate :renewable?, on: :update
  before_update :set_new_due_date

  searchable do
    string :username do
      user.try(:username)
    end
    string :user_number do
      user.try(:profile).try(:user_number)
    end
    string :item_identifier do
      item.try(:item_identifier)
    end
    time :due_date
    time :created_at
    time :checked_in_at do
      checkin.try(:created_at)
    end
    boolean :reserved do
      reserved?
    end
  end

  attr_accessor :operator

  paginates_per 10

  def is_not_checked?
    checkout = Checkout.not_returned.where(item_id: item_id)
    unless checkout.empty?
      errors.add(:base, I18n.t('activerecord.errors.messages.checkin.already_checked_out'))
    end
  end

  def renewable?
    return nil if checkin

    messages = []
    if !operator && overdue?
      messages << I18n.t('checkout.you_have_overdue_item')
    end
    if !operator && reserved?
      messages << I18n.t('checkout.this_item_is_reserved')
    end
    if !operator && over_checkout_renewal_limit?
      messages << I18n.t('checkout.excessed_renewal_limit')
    end
    if messages.empty?
      true
    else
      messages.each do |message|
        errors.add(:base, message)
      end
      false
    end
  end

  def reserved?
    return true if item.try(:reserved?)

    false
  end

  def over_checkout_renewal_limit?
    return nil unless item.checkout_status(user)
    return true if item.checkout_status(user).checkout_renewal_limit < checkout_renewal_count
  end

  def overdue?
    return false unless due_date
    if Time.zone.now > due_date.tomorrow.beginning_of_day
      return true
    else
      return false
    end
  end

  def is_today_due_date?
    if Time.zone.now.beginning_of_day == due_date.beginning_of_day
      return true
    else
      return false
    end
  end

  def set_new_due_date
    self.due_date = due_date.try(:end_of_day)
  end

  def get_new_due_date
    return nil unless user

    if item
      if checkout_renewal_count <= item.checkout_status(user).checkout_renewal_limit
        new_due_date = Time.zone.now.advance(days: item.checkout_status(user).checkout_period).beginning_of_day
      else
        new_due_date = due_date
      end
    end
  end

  def send_due_date_notification
    mailer = CheckoutMailer.due_date(self)
    mailer.deliver_later
    Message.create!(
      subject: mailer.subject,
      sender: User.find(1),
      recipient: user.username,
      body: mailer.body.to_s
    )
  end

  def send_overdue_notification
    mailer = CheckoutMailer.overdue(self)
    mailer.deliver_later
    Message.create!(
      subject: mailer.subject,
      sender: User.find(1),
      recipient: user.username,
      body: mailer.body.to_s
    )
  end

  def self.manifestations_count(start_date, end_date, manifestation)
    where(
      arel_table[:created_at].gteq start_date
    ).where(
      arel_table[:created_at].lt end_date
    )
    .where(
      item_id: manifestation.items.pluck('items.id')
    ).count
  end

  def self.send_due_date_notification
    count = 0
    User.find_each do |user|
      # 未来の日時を指定する
      user.checkouts.due_date_on(user.profile.user_group.number_of_day_to_notify_due_date.days.from_now.beginning_of_day).each_with_index do |checkout, i|
        checkout.send_due_date_notification
        count += 1
      end
    end

    count
  end

  def self.send_overdue_notification
    count = 0
    User.find_each do |user|
      user.profile.user_group.number_of_time_to_notify_overdue.times do |i|
        user.checkouts.due_date_on((user.profile.user_group.number_of_day_to_notify_overdue * (i + 1)).days.ago.beginning_of_day).each_with_index do |checkout, j|
          checkout.send_overdue_notification
          count += 1
        end
      end
    end

    count
  end

  def self.remove_all_history(user)
    user.checkouts.returned.update_all(user_id: nil)
  end
end

# == Schema Information
#
# Table name: checkouts
#
#  id                     :bigint           not null, primary key
#  user_id                :bigint
#  item_id                :bigint           not null
#  checkin_id             :integer
#  librarian_id           :bigint
#  basket_id              :bigint
#  due_date               :datetime
#  checkout_renewal_count :integer          default(0), not null
#  lock_version           :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :bigint
#  library_id             :bigint
#
