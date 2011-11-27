require 'spec_helper'

describe "CreateTypes" do
  describe "GET /create_types" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get create_types_path
      response.status.should be(302)
    end
  end
end
