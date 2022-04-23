require 'rails_helper'

describe "manifestations/show.text.ruby" do
  fixtures :all

  before(:each) do
    assign(:manifestation, manifestations(:manifestation_00001))
  end

  it "renders show" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/text/)
    expect(rendered.split("\n").count).to eq 9
  end
end
