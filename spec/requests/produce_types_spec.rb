require 'spec_helper'

describe "ProduceTypes" do
  describe "GET /produce_types" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get produce_types_path
      response.status.should be(302)
    end
  end
end
