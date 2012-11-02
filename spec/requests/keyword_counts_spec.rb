require 'spec_helper'

describe "KeywordCounts" do
  describe "GET /keyword_counts" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get keyword_counts_path
      response.status.should be(200)
    end
  end
end
