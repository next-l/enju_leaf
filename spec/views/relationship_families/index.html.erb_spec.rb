require 'spec_helper'

describe "relationship_families/index" do
  before(:each) do
    assign(:relationship_families, [
      stub_model(RelationshipFamily,
        :display_name => "Display Name",
        :description => "MyText",
        :note => "MyText"
      ),
      stub_model(RelationshipFamily,
        :display_name => "Display Name",
        :description => "MyText",
        :note => "MyText"
      )
    ])
  end

  it "renders a list of relationship_families" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
