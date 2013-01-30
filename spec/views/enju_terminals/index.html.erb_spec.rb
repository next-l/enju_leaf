require 'spec_helper'

describe "enju_terminals/index" do
  before(:each) do
    assign(:enju_terminals, [
      stub_model(EnjuTerminal,
        :ipaddr => "Ipaddr",
        :name => "Name",
        :comment => "Comment",
        :checkouts_autoprint => false,
        :reserve_autoprint => false,
        :manifestation_autoprint => false
      ),
      stub_model(EnjuTerminal,
        :ipaddr => "Ipaddr",
        :name => "Name",
        :comment => "Comment",
        :checkouts_autoprint => false,
        :reserve_autoprint => false,
        :manifestation_autoprint => false
      )
    ])
  end

  it "renders a list of enju_terminals" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Ipaddr".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Comment".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
