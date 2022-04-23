require 'rails_helper'

describe "manifestations/show.json.jbuilder" do
  fixtures :all

  before(:each) do
    assign(:manifestation, FactoryBot.create(:manifestation))
    allow(view).to receive(:policy).and_return double(show?: true, create?: false, udpate?: false, destroy?: false)
  end

  it "renders a template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/original_title/)
  end
end
