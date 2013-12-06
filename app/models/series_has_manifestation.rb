class SeriesHasManifestation < ActiveRecord::Base
  belongs_to :series_statement
  belongs_to :manifestation

#  validates_associated :series_statement, :manifestation
  validates_presence_of :series_statement_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :series_statement_id
  attr_accessible :series_statement_id, :manifestation_id, :series_statement, :manifestation

  acts_as_list :scope => :series_statement_id

  after_create :reindex
  after_destroy :reindex

  attr_accessible :series_statement_id

  paginates_per 10

  has_paper_trail

  def reindex
    series_statement.try(:index)
    manifestation.try(:index)
  end
end
