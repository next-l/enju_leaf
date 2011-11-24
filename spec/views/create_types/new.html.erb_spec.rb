require 'spec_helper'

describe "create_types/new.html.erb" do
  before(:each) do
    assign(:create_type, stub_model(CreateType,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new create_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => create_types_path, :method => "post" do
      assert_select "input#create_type_name", :name => "create_type[name]"
      assert_select "textarea#create_type_display_name", :name => "create_type[display_name]"
      assert_select "textarea#create_type_note", :name => "create_type[note]"
    end
  end
end
