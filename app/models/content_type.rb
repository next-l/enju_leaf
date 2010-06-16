class ContentType < ActiveRecord::Base
  include MasterModel
  default_scope :order => "position"
  has_many :resources
end
