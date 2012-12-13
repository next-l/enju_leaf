require 'spec_helper'

describe "remove_reasons/edit" do
  before(:each) do
    @remove_reason = assign(:remove_reason, stub_model(RemoveReason,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit remove_reason form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => remove_reasons_path(@remove_reason), :method => "post" do
      assert_select "input#remove_reason_name", :name => "remove_reason[name]"
      assert_select "textarea#remove_reason_display_name", :name => "remove_reason[display_name]"
      assert_select "textarea#remove_reason_note", :name => "remove_reason[note]"
      assert_select "input#remove_reason_position", :name => "remove_reason[position]"
    end
  end
end
