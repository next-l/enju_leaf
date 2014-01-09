require 'spec_helper'

describe "currencies/index" do
  before(:each) do
    assign(:currencies, [
      stub_model(Currency,
        :id => 1,
        :name => "Name",
        :display_name => "Display Name"
      ),
      stub_model(Currency,
        :id => 1,
        :name => "Name",
        :display_name => "Display Name"
      )
    ])
  end

  it "renders a list of currencies" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
  end
end
