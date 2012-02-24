require 'spec_helper'

describe "series_statement_merge_lists/index" do
  before(:each) do
    assign(:series_statement_merge_lists, [
      stub_model(SeriesStatementMergeList,
        :title => "Title",
        :created_at => Time.zone.now
      ),
      stub_model(SeriesStatementMergeList,
        :title => "Title",
        :created_at => Time.zone.now
      )
    ].paginate(:page => 1))
  end

  it "renders a list of series_statement_merge_lists" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Title".to_s, :count => 2
  end
end
