class ProduceType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
end
