require 'rails_helper'

describe "accepts/show" do
  fixtures :all

  before(:each) do
    @accept = assign(:accept, accepts(:one))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
