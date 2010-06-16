class ResourceRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :resource_relationships
end
