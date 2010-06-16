class Frequency < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :manifestations
end
