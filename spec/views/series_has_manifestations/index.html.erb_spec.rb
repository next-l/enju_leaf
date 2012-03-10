require 'spec_helper'

describe "series_has_manifestations/index" do
  before(:each) do
    assign(:series_has_manifestations, [
      stub_model(SeriesHasManifestation,
        :series_statement_id => 1,
        :manifestation_id => 1,
        :position => 1
      ),
      stub_model(SeriesHasManifestation,
        :series_statement_id => 1,
        :manifestation_id => 1,
        :position => 1
      )
    ].paginate(:page => 1))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders a list of series_has_manifestations" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => SeriesStatement.find(1).original_title, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => SeriesStatement.find(1).original_title, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => SeriesStatement.find(1).original_title, :count => 2
  end
end
