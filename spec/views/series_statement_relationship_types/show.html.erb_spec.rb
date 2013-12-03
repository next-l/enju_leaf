require 'spec_helper'

describe "series_statement_relationship_types/show" do
  before(:each) do
    @series_statement_relationship_type = assign(:series_statement_relationship_type, stub_model(SeriesStatementRelationshipType,
      :display_name => "Display Name",
      :typeid => 1,
      :position => 2,
      :note => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Display Name/)
    rendered.should match(/1/)
    rendered.should match(/2/)
    rendered.should match(/MyText/)
  end
end
