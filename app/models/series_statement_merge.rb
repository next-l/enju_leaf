class SeriesStatementMerge < ApplicationRecord
  belongs_to :series_statement
  belongs_to :series_statement_merge_list

  paginates_per 10
end

# == Schema Information
#
# Table name: series_statement_merges
#
#  id                             :bigint           not null, primary key
#  series_statement_id            :bigint           not null
#  series_statement_merge_list_id :bigint           not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
