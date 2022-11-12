class Basket < ApplicationRecord
  include EnjuCirculation::EnjuBasket
  default_scope { order('baskets.id DESC') }
  scope :will_expire, lambda {|date| where('created_at < ?', date)}
  belongs_to :user, optional: true
  has_many :accepts, dependent: :destroy
  has_many :withdraws, dependent: :destroy

  # 貸出完了後にかごのユーザidは破棄する
  validates :user, presence: { on: :create }
  validate :check_suspended

  attr_accessor :user_number

  def check_suspended
    if user
      errors.add(:base, I18n.t('basket.this_account_is_suspended')) if user.locked_at
    else
      errors.add(:base, I18n.t('user.not_found'))
    end
  end

  def self.expire
    Basket.will_expire(Time.zone.now.beginning_of_day).destroy_all
    logger.info "#{Time.zone.now} baskets expired!"
  end
end

# == Schema Information
#
# Table name: baskets
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  note         :text
#  lock_version :integer          default(0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
