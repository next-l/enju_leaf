class ManifestationRelationship < ActiveRecord::Base
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Manifestation'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Manifestation'
  belongs_to :manifestation_relationship_type
  validate :check_parent
  validate :check_exist_manifestation
  validates_presence_of :parent_id, :child_id
  acts_as_list :scope => :parent_id

  def check_parent
    if parent_id == child_id
      errors.add(:parent)
      errors.add(:child)
    end
  end

  def check_exist_manifestation
    parent_manifestation = Manifestation.find(parent_id) rescue errors[:base] << I18n.t('manifestation_relationships.no_parent_id')
    child_manifestation = Manifestation.find(child_id) rescue errors[:base] << I18n.t('manifestation_relationships.no_child_id')
  end
end

# == Schema Information
#
# Table name: manifestation_relationships
#
#  id                                 :integer         not null, primary key
#  parent_id                          :integer
#  child_id                           :integer
#  manifestation_relationship_type_id :integer
#  created_at                         :datetime
#  updated_at                         :datetime
#  position                           :integer
#

