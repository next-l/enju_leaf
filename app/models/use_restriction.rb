class UseRestriction < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :item_has_use_restrictions
  has_many :items, :through => :item_has_use_restrictions
  validates_presence_of :name, :display_name
  before_validation :set_display_name, :on => :create
  acts_as_list
end
