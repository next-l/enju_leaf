require 'spec_helper'

describe SeriesStatementMergeList do
  fixtures :series_statements

  it "should merge series_statment" do
    series_statement_merge_list = Factory.create(:series_statement_merge_list)
    series_statement_merge_list.merge_series_statements(SeriesStatement.all).should be_true
  end
end
