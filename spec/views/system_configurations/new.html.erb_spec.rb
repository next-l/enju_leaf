require 'spec_helper'

describe "system_configurations/new" do
  before(:each) do
    assign(:system_configuration, stub_model(SystemConfiguration).as_new_record)
  end

  it "renders new system_configuration form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => system_configurations_path, :method => "post" do
    end
  end
end
