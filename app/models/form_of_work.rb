class FormOfWork < ActiveRecord::Base
  include MasterModel
  default_scope :order => "form_of_works.position"
  has_many :works
  validates_uniqueness_of :name
end
