require 'rails_helper'

describe "page/statistics" do
  fixtures :all

  before(:each) do
    @profile = assign(:profile, profiles(:profile_admin))
    view.stub(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Statistics/)
  end
end
