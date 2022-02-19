require 'rails_helper'

describe "questions/index.rss.builder" do
  fixtures :all

  before(:each) do
    assign(:questions, Question.page(1))
    assign(:count, {query_result: Question.count})
    assign(:library_group, LibraryGroup.site_config)
    view.stub(:current_user).and_return(User.where(username: 'enjuadmin').first)
  end

  it "renders the XML template" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/http:\/\/test.host\/questions/)
  end
end
