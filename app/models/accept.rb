class Accept < ApplicationRecord
  include EnjuCirculation::EnjuAccept
  default_scope { order('accepts.id DESC') }
  belongs_to :basket
  belongs_to :item, touch: true
  belongs_to :librarian, class_name: 'User'

  validates :item_id, uniqueness: true # , message:  I18n.t('accept.already_accepted')

  attr_accessor :item_identifier

  paginates_per 10
end

# == Schema Information
#
# Table name: accepts
#
#  id           :integer          not null, primary key
#  basket_id    :integer
#  item_id      :integer
#  librarian_id :integer
#  created_at   :datetime
#  updated_at   :datetime
#
