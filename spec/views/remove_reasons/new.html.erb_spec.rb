require 'spec_helper'

describe "remove_reasons/new" do
  before(:each) do
    assign(:remove_reason, stub_model(RemoveReason,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new remove_reason form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => remove_reasons_path, :method => "post" do
      assert_select "input#remove_reason_name", :name => "remove_reason[name]"
      assert_select "textarea#remove_reason_display_name", :name => "remove_reason[display_name]"
      assert_select "textarea#remove_reason_note", :name => "remove_reason[note]"
      assert_select "input#remove_reason_position", :name => "remove_reason[position]"
    end
  end
end
