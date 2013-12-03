class SeriesStatementRelationshipType < ActiveRecord::Base
  default_scope :order => 'position'
  scope :selectable, where('typeid NOT IN (?)', [0, 9])  
  attr_accessible :display_name, :note, :position, :typeid
  paginates_per 10 
  acts_as_list
  has_many :series_statement_relationships
  validates_uniqueness_of :display_name
  validates_presence_of :display_name
  validates_numericality_of :typeid
end
