require 'spec_helper'

describe "currencies/new" do
  before(:each) do
    assign(:currency, stub_model(Currency,
      :id => 1,
      :name => "MyString",
      :display_name => "MyString"
    ).as_new_record)
  end

  it "renders new currency form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", currencies_path, "post" do
      assert_select "input#currency_id[name=?]", "currency[id]"
      assert_select "input#currency_name[name=?]", "currency[name]"
      assert_select "input#currency_display_name[name=?]", "currency[display_name]"
    end
  end
end
