require 'spec_helper'

describe "accept_types/new" do
  before(:each) do
    assign(:accept_type, stub_model(AcceptType,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new accept_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accept_types_path, :method => "post" do
      assert_select "input#accept_type_name", :name => "accept_type[name]"
      assert_select "textarea#accept_type_display_name", :name => "accept_type[display_name]"
      assert_select "textarea#accept_type_note", :name => "accept_type[note]"
      assert_select "input#accept_type_position", :name => "accept_type[position]"
    end
  end
end
