require 'spec_helper'

describe "themas/new" do
  before(:each) do
    assign(:thema, stub_model(Thema,
      :name => "MyString",
      :description => "MyText",
      :publish => 1,
      :note => "MyText",
      :position => 1
    ).as_new_record)
  end

  it "renders new thema form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", themas_path, "post" do
      assert_select "input#thema_name[name=?]", "thema[name]"
      assert_select "textarea#thema_description[name=?]", "thema[description]"
      assert_select "input#thema_publish[name=?]", "thema[publish]"
      assert_select "textarea#thema_note[name=?]", "thema[note]"
      assert_select "input#thema_position[name=?]", "thema[position]"
    end
  end
end
