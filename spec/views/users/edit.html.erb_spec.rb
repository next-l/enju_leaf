require 'spec_helper'

describe "users/edit" do
  fixtures :user_groups

  before(:each) do
    @user = assign(:user, stub_model(User,
      :username => "MyString"
    ))
    assign(:user_groups, UserGroup.all)
    assign(:libraries, Library.all)
    assign(:roles, Role.all)
    assign(:available_languages, Language.available_languages)
    view.stub(:current_user).and_return(User.friendly.find('admin'))
  end

  it "renders the edit user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path(@user), :method => "post" do
      assert_select "input#user_email", :name => "user[email]"
    end
  end
end
