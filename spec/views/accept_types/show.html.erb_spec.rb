require 'spec_helper'

describe "accept_types/show" do
  before(:each) do
    @accept_type = assign(:accept_type, stub_model(AcceptType,
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
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
  end
end
