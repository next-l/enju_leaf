class ClassificationType < ActiveRecord::Base
  include MasterModel
  has_many :classifications
end
