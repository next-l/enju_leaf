require 'spec_helper'

describe "EnjuTerminals" do
  describe "GET /enju_terminals" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get enju_terminals_path
      response.status.should be(200)
    end
  end
end
