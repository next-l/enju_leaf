require 'rails_helper'

RSpec.describe "item_custom_properties/edit", type: :view do
  before(:each) do
    @item_custom_property = assign(:item_custom_property, ItemCustomProperty.create!(
      name: "my_string",
      note: "MyText"
    ))
  end

  it "renders the edit item_custom_property form" do
    render

    assert_select "form[action=?][method=?]", item_custom_property_path(@item_custom_property), "post" do

      assert_select "input[name=?]", "item_custom_property[name]"

      assert_select "textarea[name=?]", "item_custom_property[note]"
    end
  end
end
