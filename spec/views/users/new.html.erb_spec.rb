require 'spec_helper'

describe "users/new" do
  fixtures :user_groups

  before(:each) do
    assign(:user, stub_model(User,
      :username => "MyString"
    ).as_new_record)
    assign(:user_groups, UserGroup.all)
    assign(:libraries, Library.all)
    assign(:roles, Role.all)
    assign(:available_languages, Language.available_languages)
    view.stub(:current_user).and_return(User.friendly.find('admin'))
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => users_path, :method => "post" do
      assert_select "input#user_username", :name => "user[username]"
    end
  end
end
