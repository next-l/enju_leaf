require 'spec_helper'

describe "accepts/new" do
  before(:each) do
    assign(:accept, stub_model(Accept,
      :item_id => 1
    ).as_new_record)
  end

  it "renders new accept form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => accepts_path, :method => "post" do
      assert_select "input#accept_item_id", :name => "accept[item_id]"
    end
  end
end
