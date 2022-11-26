require 'rails_helper'

describe SeriesStatementMerge do
  # pending "add some examples to (or delete) #{__FILE__}"
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
