require 'spec_helper'

describe "system_configurations/edit" do
  before(:each) do
    @system_configuration = assign(:system_configuration, stub_model(SystemConfiguration))
  end

  it "renders the edit system_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => system_configurations_path(@system_configuration), :method => "post" do
    end
  end
end
