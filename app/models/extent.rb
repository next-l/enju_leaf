class Extent < ActiveRecord::Base
  include MasterModel
  has_many :manifestations
end
