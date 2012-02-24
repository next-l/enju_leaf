require 'spec_helper'

describe "series_statement_merge_lists/show" do
  before(:each) do
    @series_statement_merge_list = assign(:series_statement_merge_list, stub_model(SeriesStatementMergeList,
      :title => "Title"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Title/)
  end
end
