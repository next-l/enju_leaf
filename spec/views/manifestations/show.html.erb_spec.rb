require 'spec_helper'

describe "manifestations/show.html.erb" do
  before(:each) do
    @manifestation = assign(:manifestation, Factory(:manifestation))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
