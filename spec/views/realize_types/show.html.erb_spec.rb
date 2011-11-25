require 'spec_helper'

describe "realize_types/show.html.erb" do
  before(:each) do
    @realize_type = assign(:realize_type, stub_model(RealizeType,
      :name => "Name",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/MyText/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
