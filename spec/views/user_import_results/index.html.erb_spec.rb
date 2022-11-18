require 'rails_helper'

describe "user_import_results/index" do
  fixtures :all

  before(:each) do
    assign(:user_import_results, UserImportResult.page(1))
    admin = User.friendly.find('enjuadmin')
    view.stub(:current_user).and_return(admin)
  end

  it "renders a list of user_import_results" do
    render
    expect(rendered).to match /enjuadmin/
  end

  context "with @user_import_file" do
    before(:each) do
      @user_import_file = UserImportFile.find(1)
      @user_import_results = UserImportResult.where(user_import_file_id: 1).page(1)
    end
    it "renders a list of user_import_results for the user_import_file" do
      render
      expect(view).to render_template "user_import_results/_list_lines"
      expect(rendered).to match /<td>1<\/td>/
    end
  end
end
