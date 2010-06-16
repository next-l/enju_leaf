class PatronRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :patron_relationships
end
