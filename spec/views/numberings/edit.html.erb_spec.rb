require 'spec_helper'

describe "numberings/edit" do
  before(:each) do
    @numbering = assign(:numbering, stub_model(Numbering,
      :name => "MyString",
      :display_name => "MyString",
      :prefix => "MyString",
      :suffix => "MyString",
      :padding => "",
      :padding_number => 1,
      :last_number => "MyString",
      :checkdigit => 1
    ))
  end

  it "renders the edit numbering form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => numberings_path(@numbering), :method => "post" do
      assert_select "input#numbering_name", :name => "numbering[name]"
      assert_select "input#numbering_display_name", :name => "numbering[display_name]"
      assert_select "input#numbering_prefix", :name => "numbering[prefix]"
      assert_select "input#numbering_suffix", :name => "numbering[suffix]"
      assert_select "input#numbering_padding", :name => "numbering[padding]"
      assert_select "input#numbering_padding_number", :name => "numbering[padding_number]"
      assert_select "input#numbering_last_number", :name => "numbering[last_number]"
      assert_select "input#numbering_checkdigit", :name => "numbering[checkdigit]"
    end
  end
end
