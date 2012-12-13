require 'spec_helper'

describe "manifestation_types/show" do
  before(:each) do
    @manifestation_type = assign(:manifestation_type, stub_model(ManifestationType,
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
