class RelationshipFamily < ActiveRecord::Base
  default_scope :order => 'id desc'
  attr_accessible :fid, :display_name, :description, :note, :series_statement_id
  has_many :series_statement_relationships, :dependent => :destroy
  has_many :series_statements

  validates_presence_of :display_name

  paginates_per 10

  searchable do
    text :fid, :display_name, :description, :note
  end
end
