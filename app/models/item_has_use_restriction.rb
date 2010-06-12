class ItemHasUseRestriction < ActiveRecord::Base
  belongs_to :item, :validate => true
  belongs_to :use_restriction, :validate => true

  def self.per_page
    10
  end

  validates_associated :item, :use_restriction
  validates_presence_of :item, :use_restriction
end
