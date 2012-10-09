require 'spec_helper'

describe "sheets/show" do
  before(:each) do
    @sheet = assign(:sheet, stub_model(Sheet,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1/)
    rendered.should match(/2/)
  end
end
