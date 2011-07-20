class ManifestationRelationshipType < ActiveRecord::Base
  include MasterModel
  default_scope :order => 'position'
  has_many :manifestation_relationships
end

# == Schema Information
#
# Table name: manifestation_relationship_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

