require 'spec_helper'

describe "series_statement_merges/edit" do
  before(:each) do
    @series_statement_merge = assign(:series_statement_merge, stub_model(SeriesStatementMerge,
      :series_statement_id => 1,
      :series_statement_merge_list_id => 1
    ))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders the edit series_statement_merge form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => series_statement_merges_path(@series_statement_merge), :method => "post" do
      assert_select "input#series_statement_merge_series_statement_id", :name => "series_statement_merge[series_statement_id]"
      assert_select "input#series_statement_merge_series_statement_merge_list_id", :name => "series_statement_merge[series_statement_merge_list_id]"
    end
  end
end
