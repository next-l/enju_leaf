require 'spec_helper'

describe "SeriesStatementMergeLists" do
  describe "GET /series_statement_merge_lists" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get series_statement_merge_lists_path
      response.status.should be(302)
    end
  end
end
