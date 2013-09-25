require 'spec_helper'

describe "themas/edit" do
  before(:each) do
    @thema = assign(:thema, stub_model(Thema,
      :name => "MyString",
      :description => "MyText",
      :publish => 1,
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit thema form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", thema_path(@thema), "post" do
      assert_select "input#thema_name[name=?]", "thema[name]"
      assert_select "textarea#thema_description[name=?]", "thema[description]"
      assert_select "input#thema_publish[name=?]", "thema[publish]"
      assert_select "textarea#thema_note[name=?]", "thema[note]"
      assert_select "input#thema_position[name=?]", "thema[position]"
    end
  end
end
