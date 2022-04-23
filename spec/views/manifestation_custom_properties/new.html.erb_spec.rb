require 'rails_helper'

RSpec.describe "manifestation_custom_properties/new", type: :view do
  before(:each) do
    assign(:manifestation_custom_property, ManifestationCustomProperty.new(
      name: "my_string",
      note: "MyText"
    ))
  end

  it "renders new manifestation_custom_property form" do
    render

    assert_select "form[action=?][method=?]", manifestation_custom_properties_path, "post" do

      assert_select "input[name=?]", "manifestation_custom_property[name]"

      assert_select "textarea[name=?]", "manifestation_custom_property[note]"
    end
  end
end
