require 'spec_helper'

describe "series_statement_merge_lists/new" do
  before(:each) do
    assign(:series_statement_merge_list, stub_model(SeriesStatementMergeList,
      :title => "MyString"
    ).as_new_record)
  end

  it "renders new series_statement_merge_list form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => series_statement_merge_lists_path, :method => "post" do
      assert_select "input#series_statement_merge_list_title", :name => "series_statement_merge_list[title]"
    end
  end
end
