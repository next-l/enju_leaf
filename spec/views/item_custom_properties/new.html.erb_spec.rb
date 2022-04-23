require 'rails_helper'

RSpec.describe "item_custom_properties/new", type: :view do
  before(:each) do
    assign(:item_custom_property, ItemCustomProperty.new(
      name: "my_string",
      note: "MyText"
    ))
  end

  it "renders new item_custom_property form" do
    render

    assert_select "form[action=?][method=?]", item_custom_properties_path, "post" do

      assert_select "input[name=?]", "item_custom_property[name]"

      assert_select "textarea[name=?]", "item_custom_property[note]"
    end
  end
end
