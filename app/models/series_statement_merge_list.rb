class SeriesStatementMergeList < ApplicationRecord
  has_many :series_statement_merges, dependent: :destroy
  has_many :series_statements, through: :series_statement_merges
  validates :title, presence: true

  paginates_per 10
end
