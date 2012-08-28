require 'spec_helper'

describe "system_configurations/index" do
  before(:each) do
    assign(:system_configurations, [
      stub_model(SystemConfiguration),
      stub_model(SystemConfiguration)
    ])
  end

  it "renders a list of system_configurations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
  end
end
