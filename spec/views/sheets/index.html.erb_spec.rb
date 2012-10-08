require 'spec_helper'

describe "sheets/index" do
  before(:each) do
    assign(:sheets, [
      stub_model(Sheet,
        :name => "Name",
        :note => "MyText",
        :height => 1.5,
        :width => 1.5,
        :margin_h => 1.5,
        :margin_w => 1.5,
        :space_h => 1.5,
        :space_w => 1.5,
        :cell_x => 1,
        :cell_y => 2
      ),
      stub_model(Sheet,
        :name => "Name",
        :note => "MyText",
        :height => 1.5,
        :width => 1.5,
        :margin_h => 1.5,
        :margin_w => 1.5,
        :space_h => 1.5,
        :space_w => 1.5,
        :cell_x => 1,
        :cell_y => 2
      )
    ])
  end

  it "renders a list of sheets" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
  end
end
