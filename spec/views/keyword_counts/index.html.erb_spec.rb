require 'spec_helper'

describe "keyword_counts/index" do
  before(:each) do
    assign(:keyword_counts, [
      stub_model(KeywordCount,
        :date => "",
        :keyword => "",
        :count => 1
      ),
      stub_model(KeywordCount,
        :date => "",
        :keyword => "",
        :count => 1
      )
    ])
  end

  it "renders a list of keyword_counts" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => "".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end
