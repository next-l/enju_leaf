require 'spec_helper'

describe "series_statement_merges/new" do
  before(:each) do
    assign(:series_statement_merge, stub_model(SeriesStatementMerge,
      :series_statement_id => 1,
      :series_statement_merge_list_id => 1
    ).as_new_record)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders new series_statement_merge form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => series_statement_merges_path, :method => "post" do
      assert_select "input#series_statement_merge_series_statement_id", :name => "series_statement_merge[series_statement_id]"
      assert_select "input#series_statement_merge_series_statement_merge_list_id", :name => "series_statement_merge[series_statement_merge_list_id]"
    end
  end
end
