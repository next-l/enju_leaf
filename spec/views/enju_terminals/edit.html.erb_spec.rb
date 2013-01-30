require 'spec_helper'

describe "enju_terminals/edit" do
  before(:each) do
    @enju_terminal = assign(:enju_terminal, stub_model(EnjuTerminal,
      :ipaddr => "MyString",
      :name => "MyString",
      :comment => "MyString",
      :checkouts_autoprint => false,
      :reserve_autoprint => false,
      :manifestation_autoprint => false
    ))
  end

  it "renders the edit enju_terminal form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => enju_terminals_path(@enju_terminal), :method => "post" do
      assert_select "input#enju_terminal_ipaddr", :name => "enju_terminal[ipaddr]"
      assert_select "input#enju_terminal_name", :name => "enju_terminal[name]"
      assert_select "input#enju_terminal_comment", :name => "enju_terminal[comment]"
      assert_select "input#enju_terminal_checkouts_autoprint", :name => "enju_terminal[checkouts_autoprint]"
      assert_select "input#enju_terminal_reserve_autoprint", :name => "enju_terminal[reserve_autoprint]"
      assert_select "input#enju_terminal_manifestation_autoprint", :name => "enju_terminal[manifestation_autoprint]"
    end
  end
end
