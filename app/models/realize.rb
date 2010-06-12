class Realize < ActiveRecord::Base
  belongs_to :patron
  belongs_to :expression, :class_name => 'Resource', :foreign_key => 'expression_id'

  validates_associated :patron, :expression
  validates_presence_of :patron, :expression
  validates_uniqueness_of :expression_id, :scope => :patron_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :expression

  def self.per_page
    10
  end

  def reindex
    patron.index
    expression.index
  end

end
