require 'spec_helper'

describe "profiles/new" do
  fixtures :user_groups

  before(:each) do
    assign(:profile, stub_model(Profile,
      :user_group_id => 1
    ).as_new_record)
    assign(:user_groups, UserGroup.all)
    assign(:libraries, Library.all)
    assign(:roles, Role.all)
    assign(:available_languages, Language.available_languages)
    view.stub(:current_user).and_return(User.find('admin'))
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => profiles_path, :method => "post" do
      assert_select "input#profile_user_number", :name => "profile[user_number]"
    end
  end
end
