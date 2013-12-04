require 'spec_helper'

describe "series_statement_relationship_types/index" do
  before(:each) do
    assign(:series_statement_relationship_types, [
      stub_model(SeriesStatementRelationshipType,
        :display_name => "Display Name",
        :typeid => 1,
        :position => 2,
        :note => "MyText"
      ),
      stub_model(SeriesStatementRelationshipType,
        :display_name => "Display Name",
        :typeid => 1,
        :position => 2,
        :note => "MyText"
      )
    ])
  end

  it "renders a list of series_statement_relationship_types" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
