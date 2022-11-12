class Withdraw < ApplicationRecord
  include EnjuCirculation::EnjuWithdraw
  belongs_to :basket
  belongs_to :item, touch: true
  belongs_to :librarian, class_name: 'User'

  validates :item_id,
    uniqueness: true #{ message: I18n.t('withdraw.already_withdrawn', locale: I18n.default_locale) }

  attr_accessor :item_identifier

  paginates_per 10
end

# == Schema Information
#
# Table name: withdraws
#
#  id           :bigint           not null, primary key
#  basket_id    :integer
#  item_id      :bigint
#  librarian_id :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
