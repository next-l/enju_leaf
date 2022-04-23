require 'rails_helper'

RSpec.describe "manifestation_custom_properties/edit", type: :view do
  before(:each) do
    @manifestation_custom_property = assign(:manifestation_custom_property, ManifestationCustomProperty.create!(
      name: "my_string",
      note: "MyText"
    ))
  end

  it "renders the edit manifestation_custom_property form" do
    render

    assert_select "form[action=?][method=?]", manifestation_custom_property_path(@manifestation_custom_property), "post" do

      assert_select "input[name=?]", "manifestation_custom_property[name]"

      assert_select "textarea[name=?]", "manifestation_custom_property[note]"
    end
  end
end
