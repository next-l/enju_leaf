class CheckedManifestation < ActiveRecord::Base
  validates_uniqueness_of :manifestation_id, :scope => :basket_id
  belongs_to :manifestation
  belongs_to :basket
end
