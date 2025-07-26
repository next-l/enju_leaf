require 'rails_helper'

describe "user_export_files/new" do
  before(:each) do
    assign(:user_export_file, UserExportFile.new)
    view.stub(:current_user).and_return(User.find_by(username: 'enjuadmin'))
  end

  it "renders new user form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", action: user_export_files_path, method: "post" do
      assert_select "input", name: "commit"
    end
  end
end
