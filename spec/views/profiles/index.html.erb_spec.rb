require 'spec_helper'

describe "profiles/index" do
  fixtures :all

  before(:each) do
    assign(:profiles, Profile.page(1))
    admin = User.friendly.find('enjuadmin')
    view.stub(:current_user).and_return(admin)
  end

  it "renders a list of profiles" do
    allow(view).to receive(:policy).and_return double(create?: true, update?: true, destroy?: true)
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 'enjuadmin'
  end
end
