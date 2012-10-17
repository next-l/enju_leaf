class SeriesStatementRelationship < ActiveRecord::Base
  attr_accessible :child_id, :parent_id
  belongs_to :parent, :foreign_key => 'parent_id', :class_name => 'SeriesStatement'
  belongs_to :child, :foreign_key => 'child_id', :class_name => 'SeriesStatement'
  after_save :reindex
  after_destroy :reindex

  validates_presence_of :parent_id, :child_id
  validates_uniqueness_of :child_id, :scope => :parent_id
  acts_as_list :scope => :parent_id

  def reindex
    parent.try(:index)
    child.try(:index)
    Sunspot.commit
  end
end
