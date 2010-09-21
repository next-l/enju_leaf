class ResourceRelationship < ActiveRecord::Base
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Resource'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Resource'
  belongs_to :resource_relationship_type
  validate :check_parent
  validates_presence_of :parent_id, :child_id
  acts_as_list :scope => :parent_id

  def check_parent
    if parent_id == child_id
      errors.add(:parent)
      errors.add(:child)
    end
  end
end
