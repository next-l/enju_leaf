require 'spec_helper'

describe "terminals/edit" do
  before(:each) do
    @terminal = assign(:terminal, stub_model(Terminal,
      :ipaddr => "MyString",
      :name => "MyString",
      :comment => "MyString",
      :checkouts_autoprint => false,
      :reserve_autoprint => false,
      :manifestation_autoprint => false
    ))
  end

  it "renders the edit terminal form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => terminals_path(@terminal), :method => "post" do
      assert_select "input#terminal_ipaddr", :name => "terminal[ipaddr]"
      assert_select "input#terminal_name", :name => "terminal[name]"
      assert_select "input#terminal_comment", :name => "terminal[comment]"
      assert_select "input#terminal_checkouts_autoprint", :name => "terminal[checkouts_autoprint]"
      assert_select "input#terminal_reserve_autoprint", :name => "terminal[reserve_autoprint]"
      assert_select "input#terminal_manifestation_autoprint", :name => "terminal[manifestation_autoprint]"
    end
  end
end
