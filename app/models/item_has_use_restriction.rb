class ItemHasUseRestriction < ActiveRecord::Base
  belongs_to :item, :validate => true
  belongs_to :use_restriction, :validate => true

  validates_associated :item, :use_restriction
  validates_presence_of :item, :use_restriction

  paginates_per 10
end
