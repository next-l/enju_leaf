require 'spec_helper'

describe "series_statement_merge_lists/edit" do
  before(:each) do
    @series_statement_merge_list = assign(:series_statement_merge_list, stub_model(SeriesStatementMergeList,
      :title => "MyString"
    ))
  end

  it "renders the edit series_statement_merge_list form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => series_statement_merge_lists_path(@series_statement_merge_list), :method => "post" do
      assert_select "input#series_statement_merge_list_title", :name => "series_statement_merge_list[title]"
    end
  end
end
