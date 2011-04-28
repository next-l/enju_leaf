class Frequency < ActiveRecord::Base
  include MasterModel
  has_many :manifestations
end
