require 'spec_helper'

describe "relationship_families/new" do
  before(:each) do
    assign(:relationship_family, stub_model(RelationshipFamily,
      :display_name => "MyString",
      :description => "MyText",
      :note => "MyText"
    ).as_new_record)
  end

  it "renders new relationship_family form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", relationship_families_path, "post" do
      assert_select "input#relationship_family_display_name[name=?]", "relationship_family[display_name]"
      assert_select "textarea#relationship_family_description[name=?]", "relationship_family[description]"
      assert_select "textarea#relationship_family_note[name=?]", "relationship_family[note]"
    end
  end
end
