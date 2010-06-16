class CirculationStatus < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  scope :available_for_checkout, :conditions => {:name => ['Available On Shelf']}
  has_many :items
end
