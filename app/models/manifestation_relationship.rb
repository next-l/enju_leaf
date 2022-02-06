class ManifestationRelationship < ApplicationRecord
  belongs_to :parent, foreign_key: 'parent_id', class_name: 'Manifestation'
  belongs_to :child, foreign_key: 'child_id', class_name: 'Manifestation'
  belongs_to :manifestation_relationship_type, optional: true
  validate :check_parent
  acts_as_list scope: :parent_id

  def check_parent
    if parent_id == child_id
      errors.add(:parent)
      errors.add(:child)
    end
  end
end

# == Schema Information
#
# Table name: manifestation_relationships
#
#  id                                 :integer          not null, primary key
#  parent_id                          :integer
#  child_id                           :integer
#  manifestation_relationship_type_id :integer
#  created_at                         :datetime
#  updated_at                         :datetime
#  position                           :integer
#
