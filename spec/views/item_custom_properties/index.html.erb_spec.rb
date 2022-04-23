require 'rails_helper'

RSpec.describe "item_custom_properties/index", type: :view do
  before(:each) do
    assign(:item_custom_properties, [
      ItemCustomProperty.create!(
        name: "name1",
        display_name: "カスタム項目1",
        note: "MyText"
      ),
      ItemCustomProperty.create!(
        name: "name2",
        display_name: "カスタム項目2",
        note: "MyText"
      )
    ])
  end

  it "renders a list of item_custom_properties" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true, destroy?: true)
    render
    assert_select "tr>td", text: "name1".to_s, count: 1
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
