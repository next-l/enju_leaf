require 'spec_helper'

describe "remove_reasons/show" do
  before(:each) do
    @remove_reason = assign(:remove_reason, stub_model(RemoveReason,
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
