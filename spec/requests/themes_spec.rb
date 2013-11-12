require 'spec_helper'

describe "Themes" do
  describe "GET /themes" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get themes_path
      response.status.should be(200)
    end
  end
end
