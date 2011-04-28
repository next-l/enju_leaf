class SubjectType < ActiveRecord::Base
  include MasterModel
  has_many :subjects
end
