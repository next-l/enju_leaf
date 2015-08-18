require 'spec_helper'

describe "profiles/index" do
  fixtures :all

  before(:each) do
    assign(:profiles, Profile.page(1))
    admin = User.find('enjuadmin')
    view.stub(:current_user).and_return(admin)
    @ability = EnjuLeaf::Ability.new(admin, '0.0.0.0')
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders a list of profiles" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 'enjuadmin'
  end
end
