require 'spec_helper'

describe "create_types/edit" do
  before(:each) do
    @create_type = assign(:create_type, stub_model(CreateType,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit create_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => create_types_path(@create_type), :method => "post" do
      assert_select "input#create_type_name", :name => "create_type[name]"
      assert_select "textarea#create_type_display_name", :name => "create_type[display_name]"
      assert_select "textarea#create_type_note", :name => "create_type[note]"
    end
  end
end
