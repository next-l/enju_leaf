class SeriesStatementMerge < ActiveRecord::Base
  belongs_to :series_statement, :validate => true
  belongs_to :series_statement_merge_list, :validate => true
  validates_presence_of :series_statement, :series_statement_merge_list
  validates_associated :series_statement, :series_statement_merge_list

  paginates_per 10
end

# == Schema Information
#
# Table name: series_statement_merges
#
#  id                             :integer         not null, primary key
#  series_statement_id            :integer         not null
#  series_statement_merge_list_id :integer         not null
#  created_at                     :datetime
#  updated_at                     :datetime
#

