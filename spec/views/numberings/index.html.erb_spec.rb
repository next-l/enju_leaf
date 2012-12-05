require 'spec_helper'

describe "numberings/index" do
  before(:each) do
    assign(:numberings, [
      stub_model(Numbering,
        :name => "Name",
        :display_name => "Display Name",
        :prefix => "Prefix",
        :suffix => "Suffix",
        :padding => "",
        :padding_number => 1,
        :last_number => "Last Number",
        :checkdigit => 2
      ),
      stub_model(Numbering,
        :name => "Name",
        :display_name => "Display Name",
        :prefix => "Prefix",
        :suffix => "Suffix",
        :padding => "",
        :padding_number => 1,
        :last_number => "Last Number",
        :checkdigit => 2
      )
    ])
  end

  it "renders a list of numberings" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Display Name".to_s, :count => 2
    assert_select "tr>td", :text => "Prefix".to_s, :count => 2
    assert_select "tr>td", :text => "Suffix".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Last Number".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
