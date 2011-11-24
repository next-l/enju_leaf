require 'spec_helper'

describe "RealizeTypes" do
  describe "GET /realize_types" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get realize_types_path
      response.status.should be(302)
    end
  end
end
