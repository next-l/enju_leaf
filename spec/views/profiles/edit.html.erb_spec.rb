require 'spec_helper'

describe "profiles/edit" do
  fixtures :all

  before(:each) do
    @profile = assign(:profile, profiles(:admin))
    assign(:user_groups, UserGroup.all)
    assign(:libraries, Library.all)
    assign(:roles, Role.all)
    assign(:available_languages, Language.available_languages)
    view.stub(:current_user).and_return(User.find('enjuadmin'))
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders the edit user form" do
    render
    assert_select "form", :action => profiles_path(@profile), :method => "post" do
      assert_select "input#profile_user_number", :name => "profile[user_number]"
    end
  end

  describe "when logged in as librarian" do
    before(:each) do
      @profile = assign(:profile, profiles(:librarian2))
      user = users(:librarian1)
      view.stub(:current_user).and_return(user)
      @ability = EnjuLeaf::Ability.new(user, '0.0.0.0')
      @ability.extend(CanCan::Ability)
      controller.stub(:current_ability) { @ability }
    end

    it "should not display 'delete' link" do
      render
      expect(rendered).not_to have_selector("a[href='#{profile_path(@profile.id)}'][data-method='delete']") 
    end
  end
end
