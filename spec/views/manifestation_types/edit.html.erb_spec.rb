require 'spec_helper'

describe "manifestation_types/edit" do
  before(:each) do
    @manifestation_type = assign(:manifestation_type, stub_model(ManifestationType,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit manifestation_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => manifestation_types_path(@manifestation_type), :method => "post" do
      assert_select "input#manifestation_type_name", :name => "manifestation_type[name]"
      assert_select "textarea#manifestation_type_display_name", :name => "manifestation_type[display_name]"
      assert_select "textarea#manifestation_type_note", :name => "manifestation_type[note]"
      assert_select "input#manifestation_type_position", :name => "manifestation_type[position]"
    end
  end
end
