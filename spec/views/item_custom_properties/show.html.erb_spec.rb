require 'rails_helper'

RSpec.describe "item_custom_properties/show", type: :view do
  before(:each) do
    @item_custom_property = assign(:item_custom_property, ItemCustomProperty.create!(
      name: "name",
      note: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/name/)
    expect(rendered).to match(/MyText/)
  end
end
