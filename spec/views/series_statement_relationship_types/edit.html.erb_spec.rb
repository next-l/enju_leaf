require 'spec_helper'

describe "series_statement_relationship_types/edit" do
  before(:each) do
    @series_statement_relationship_type = assign(:series_statement_relationship_type, stub_model(SeriesStatementRelationshipType,
      :display_name => "MyString",
      :typeid => 1,
      :position => 1,
      :note => "MyText"
    ))
  end

  it "renders the edit series_statement_relationship_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", series_statement_relationship_type_path(@series_statement_relationship_type), "post" do
      assert_select "input#series_statement_relationship_type_display_name[name=?]", "series_statement_relationship_type[display_name]"
      assert_select "input#series_statement_relationship_type_typeid[name=?]", "series_statement_relationship_type[typeid]"
      assert_select "input#series_statement_relationship_type_position[name=?]", "series_statement_relationship_type[position]"
      assert_select "textarea#series_statement_relationship_type_note[name=?]", "series_statement_relationship_type[note]"
    end
  end
end
