class SubjectType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :subjects
end
