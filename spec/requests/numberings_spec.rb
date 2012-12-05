require 'spec_helper'

describe "Numberings" do
  describe "GET /numberings" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get numberings_path
      response.status.should be(200)
    end
  end
end
