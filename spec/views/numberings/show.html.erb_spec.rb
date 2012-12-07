require 'spec_helper'

describe "numberings/show" do
  before(:each) do
    @numbering = assign(:numbering, stub_model(Numbering,
      :name => "Name",
      :display_name => "Display Name",
      :prefix => "Prefix",
      :suffix => "Suffix",
      :padding => "",
      :padding_number => 1,
      :last_number => "Last Number",
      :checkdigit => 2
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/Display Name/)
    rendered.should match(/Prefix/)
    rendered.should match(/Suffix/)
    rendered.should match(//)
    rendered.should match(/1/)
    rendered.should match(/Last Number/)
    rendered.should match(/2/)
  end
end
