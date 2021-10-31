class ItemHasUseRestriction < ApplicationRecord
  belongs_to :item, validate: true
  belongs_to :use_restriction, validate: true
  accepts_nested_attributes_for :use_restriction

  validates_associated :item, :use_restriction
  validates :use_restriction, presence: true
  validates :item, presence: { on: :update }

  paginates_per 10
end

# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :integer          not null, primary key
#  item_id            :integer          not null
#  use_restriction_id :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#
