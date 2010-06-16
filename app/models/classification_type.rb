class ClassificationType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :classifications
end
