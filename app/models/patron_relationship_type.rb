class PatronRelationshipType < ActiveRecord::Base
  include MasterModel
  has_many :patron_relationships
end
