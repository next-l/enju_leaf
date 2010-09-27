class ManifestationRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :manifestation_relationships
end
