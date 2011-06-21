class UseRestriction < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  scope :available, where(:name => ['Not For Loan', 'Limited Circulation, Normal Loan Period'])
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions
  attr_protected :name
end
