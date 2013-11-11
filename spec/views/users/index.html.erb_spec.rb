require 'spec_helper'

describe "users/index" do
  fixtures :all

  before(:each) do
    assign(:users, User.page(1))
    view.stub(:current_user).and_return(User.friendly.find('admin'))
  end

  it "renders a list of users" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 'admin'
  end
end
