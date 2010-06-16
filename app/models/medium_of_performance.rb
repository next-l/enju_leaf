class MediumOfPerformance < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :works
end
