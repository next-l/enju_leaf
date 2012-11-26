require 'spec_helper'

describe "retention_periods/edit" do
  before(:each) do
    @retention_period = assign(:retention_period, stub_model(RetentionPeriod,
      :name => "MyString",
      :display_name => "MyText",
      :note => "MyText",
      :position => 1
    ))
  end

  it "renders the edit retention_period form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => retention_periods_path(@retention_period), :method => "post" do
      assert_select "input#retention_period_name", :name => "retention_period[name]"
      assert_select "textarea#retention_period_display_name", :name => "retention_period[display_name]"
      assert_select "textarea#retention_period_note", :name => "retention_period[note]"
      assert_select "input#retention_period_position", :name => "retention_period[position]"
    end
  end
end
