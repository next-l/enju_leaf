class PatronRelationshipType < ActiveRecord::Base
  attr_accessible :name, :display_name, :note
  include MasterModel
  default_scope :order => 'patron_relationship_types.position'
  has_many :patron_relationships
end

# == Schema Information
#
# Table name: patron_relationship_types
#
#  id           :integer         not null, primary key
#  name         :string(255)     not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime
#  updated_at   :datetime
#

