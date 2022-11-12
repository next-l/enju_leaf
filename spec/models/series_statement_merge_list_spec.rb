require 'rails_helper'

describe SeriesStatementMergeList do
  fixtures :all

  it "should merge series_statement" do
    series_statement_merge_list = series_statement_merge_lists(:series_statement_merge_list_00001)
  end
end

# == Schema Information
#
# Table name: series_statement_merge_lists
#
#  id         :bigint           not null, primary key
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
