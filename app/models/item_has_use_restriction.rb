class ItemHasUseRestriction < ActiveRecord::Base
  attr_accessible :item_id, :use_restriction_id

  belongs_to :item, :validate => true
  belongs_to :use_restriction, :validate => true

  paginates_per 10

  validates_associated :item, :use_restriction
  validates_presence_of :item, :use_restriction
end

# == Schema Information
#
# Table name: item_has_use_restrictions
#
#  id                 :integer         not null, primary key
#  item_id            :integer         not null
#  use_restriction_id :integer         not null
#  created_at         :datetime
#  updated_at         :datetime
#

