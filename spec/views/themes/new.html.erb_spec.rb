require 'spec_helper'

describe "themes/new" do
  before(:each) do
    assign(:theme, stub_model(Theme,
      :name => "MyString",
      :description => "MyText",
      :publish => 1,
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new theme form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", themes_path, "post" do
      assert_select "input#theme_name[name=?]", "theme[name]"
      assert_select "textarea#theme_description[name=?]", "theme[description]"
      assert_select "input#theme_publish[name=?]", "theme[publish]"
      assert_select "textarea#theme_note[name=?]", "theme[note]"
      assert_select "input#theme_position[name=?]", "theme[position]"
    end
  end
end
