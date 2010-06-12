class Produce < ActiveRecord::Base
  belongs_to :patron
  belongs_to :manifestation, :class_name => 'Resource'

  validates_associated :patron, :manifestation
  validates_presence_of :patron, :manifestation
  validates_uniqueness_of :manifestation_id, :scope => :patron_id
  after_save :reindex
  after_destroy :reindex

  acts_as_list :scope => :manifestation

  def self.per_page
    10
  end

  def reindex
    patron.index
    manifestation.index
  end

end
