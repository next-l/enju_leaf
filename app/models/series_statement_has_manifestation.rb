class SeriesStatementHasManifestation < ActiveRecord::Base
  belongs_to :series_statement
  belongs_to :manifestation

  validates_associated :series_statement, :manifestation
  validates_presence_of :series_statement_id, :manifestation_id
  validates_uniqueness_of :manifestation_id, :scope => :series_statement_id

  acts_as_list :scope => :series_statement_id

  def self.per_page
    10
  end
end
