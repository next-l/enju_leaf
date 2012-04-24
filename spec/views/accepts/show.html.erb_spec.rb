require 'spec_helper'

describe "accepts/show" do
  before(:each) do
    @accept = assign(:accept, stub_model(Accept,
      :item_id => 1,
      :librarian_id => 1,
      :created_at => Time.zone.now
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
