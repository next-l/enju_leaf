require 'spec_helper'

describe "SeriesHasManifestations" do
  describe "GET /series_has_manifestations" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get series_has_manifestations_path
      response.status.should be(302)
    end
  end
end
