class FormOfWork < ActiveRecord::Base
  include MasterModel
  has_many :works
  validates_uniqueness_of :name
end
