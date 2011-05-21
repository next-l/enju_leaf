class CirculationStatus < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  scope :available_for_checkout, where(:name => 'Available On Shelf')
  has_many :items
  attr_protected :name
end
