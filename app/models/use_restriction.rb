class UseRestriction < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions
end
