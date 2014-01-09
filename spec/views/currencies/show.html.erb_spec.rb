require 'spec_helper'

describe "currencies/show" do
  before(:each) do
    @currency = assign(:currency, stub_model(Currency,
      :id => 1,
      :name => "Name",
      :display_name => "Display Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Name/)
    rendered.should match(/Display Name/)
  end
end
