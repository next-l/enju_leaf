class PatronRelationship < ActiveRecord::Base
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'Patron'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'Patron'
  belongs_to :patron_relationship_type
  validate :check_parent
  validates_presence_of :parent_id, :child_id
  acts_as_list :scope => :parent_id

  def check_parent
    errors.add(:parent) if parent_id == child_id
  end
end
