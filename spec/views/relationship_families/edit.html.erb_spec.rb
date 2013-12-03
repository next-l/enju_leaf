require 'spec_helper'

describe "relationship_families/edit" do
  before(:each) do
    @relationship_family = assign(:relationship_family, stub_model(RelationshipFamily,
      :display_name => "MyString",
      :description => "MyText",
      :note => "MyText"
    ))
  end

  it "renders the edit relationship_family form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", relationship_family_path(@relationship_family), "post" do
      assert_select "input#relationship_family_display_name[name=?]", "relationship_family[display_name]"
      assert_select "textarea#relationship_family_description[name=?]", "relationship_family[description]"
      assert_select "textarea#relationship_family_note[name=?]", "relationship_family[note]"
    end
  end
end
