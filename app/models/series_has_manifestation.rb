class SeriesHasManifestation < ActiveRecord::Base
  belongs_to :series_statement
  belongs_to :manifestation

  validates_associated :series_statement, :manifestation
  validates_presence_of :series_statement_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :series_statement_id

  acts_as_list :scope => :series_statement_id

  after_create :reindex
  after_destroy :reindex

  def self.per_page
    10
  end

  def reindex
    series_statement.try(:index)
    manifestation.try(:index)
  end
end
