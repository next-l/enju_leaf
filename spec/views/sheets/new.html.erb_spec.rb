require 'spec_helper'

describe "sheets/new" do
  before(:each) do
    assign(:sheet, stub_model(Sheet,
      :name => "MyString",
      :note => "MyText",
      :height => 1.5,
      :width => 1.5,
      :margin_h => 1.5,
      :margin_w => 1.5,
      :space_h => 1.5,
      :space_w => 1.5,
      :cell_x => 1,
      :cell_y => 1
    ).as_new_record)
  end

  it "renders new sheet form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => sheets_path, :method => "post" do
      assert_select "input#sheet_name", :name => "sheet[name]"
      assert_select "textarea#sheet_note", :name => "sheet[note]"
      assert_select "input#sheet_height", :name => "sheet[height]"
      assert_select "input#sheet_width", :name => "sheet[width]"
      assert_select "input#sheet_margin_h", :name => "sheet[margin_h]"
      assert_select "input#sheet_margin_w", :name => "sheet[margin_w]"
      assert_select "input#sheet_space_h", :name => "sheet[space_h]"
      assert_select "input#sheet_space_w", :name => "sheet[space_w]"
      assert_select "input#sheet_cell_x", :name => "sheet[cell_x]"
      assert_select "input#sheet_cell_y", :name => "sheet[cell_y]"
    end
  end
end
