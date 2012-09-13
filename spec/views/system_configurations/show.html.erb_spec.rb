require 'spec_helper'

describe "system_configurations/show" do
  before(:each) do
    @system_configuration = assign(:system_configuration, stub_model(SystemConfiguration))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
