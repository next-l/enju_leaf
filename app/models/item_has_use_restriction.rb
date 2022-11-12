class ItemHasUseRestriction < ApplicationRecord
  belongs_to :item
  belongs_to :use_restriction
  accepts_nested_attributes_for :use_restriction

  validates :item, presence: { on: :update }

  paginates_per 10
end

# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :bigint           not null, primary key
#  item_id            :integer          not null
#  use_restriction_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
