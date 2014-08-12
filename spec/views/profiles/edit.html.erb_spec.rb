require 'spec_helper'

describe "profiles/edit" do
  fixtures :all

  before(:each) do
    @profile = assign(:profile, profiles(:admin))
    assign(:user_groups, UserGroup.all)
    assign(:libraries, Library.all)
    assign(:roles, Role.all)
    assign(:available_languages, Language.available_languages)
    view.stub(:current_user).and_return(User.find('admin'))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => profiles_path(@profile), :method => "post" do
      assert_select "input#profile_user_number", :name => "profile[user_number]"
    end
  end
end
