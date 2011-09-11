require 'spec_helper'

describe "SeriesStatementMerges" do
  describe "GET /series_statement_merges" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get series_statement_merges_path
      response.status.should be(302)
    end
  end
end
