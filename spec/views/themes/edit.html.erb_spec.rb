require 'spec_helper'

describe "themes/edit" do
  before(:each) do
    @theme = assign(:theme, stub_model(Theme,
      :name => "MyString",
      :description => "MyText",
      :publish => 1,
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit theme form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", theme_path(@theme), "post" do
      assert_select "input#theme_name[name=?]", "theme[name]"
      assert_select "textarea#theme_description[name=?]", "theme[description]"
      assert_select "input#theme_publish[name=?]", "theme[publish]"
      assert_select "textarea#theme_note[name=?]", "theme[note]"
      assert_select "input#theme_position[name=?]", "theme[position]"
    end
  end
end
