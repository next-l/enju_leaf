require 'spec_helper'

describe "produce_types/new.html.erb" do
  before(:each) do
    assign(:produce_type, stub_model(ProduceType,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new produce_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => produce_types_path, :method => "post" do
      assert_select "input#produce_type_name", :name => "produce_type[name]"
      assert_select "textarea#produce_type_display_name", :name => "produce_type[display_name]"
      assert_select "textarea#produce_type_note", :name => "produce_type[note]"
    end
  end
end
