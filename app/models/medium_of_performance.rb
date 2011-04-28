class MediumOfPerformance < ActiveRecord::Base
  include MasterModel
  has_many :works
end
