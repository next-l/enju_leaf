require 'spec_helper'

describe "series_statement_merges/index" do
  before(:each) do
    assign(:series_statement_merges, [
      stub_model(SeriesStatementMerge,
        :series_statement_id => 1,
        :series_statement_merge_list_id => 1
      ),
      stub_model(SeriesStatementMerge,
        :series_statement_id => 1,
        :series_statement_merge_list_id => 2
      )
    ].paginate(:page => 1))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders a list of series_statement_merges" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td"
  end
end
