require 'rails_helper'

describe "budget_types/new" do
  before(:each) do
    assign(:budget_type, BudgetType.new(
      name: "MyString",
      display_name: "MyText",
      note: "MyText",
      position: 1
    ))
  end

  it "renders new budget_type form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: budget_types_path, method: "post" do
      assert_select "input#budget_type_name", name: "budget_type[name]"
      assert_select "textarea#budget_type_display_name", name: "budget_type[display_name]"
      assert_select "textarea#budget_type_note", name: "budget_type[note]"
    end
  end
end
