require 'spec_helper'

describe "series_statement_merges/show" do
  before(:each) do
    @series_statement_merge = assign(:series_statement_merge, Factory(:series_statement_merge))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
  end
end
