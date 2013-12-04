require 'spec_helper'

describe "relationship_families/show" do
  before(:each) do
    @relationship_family = assign(:relationship_family, stub_model(RelationshipFamily,
      :display_name => "Display Name",
      :description => "MyText",
      :note => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Display Name/)
    rendered.should match(/MyText/)
    rendered.should match(/MyText/)
  end
end
