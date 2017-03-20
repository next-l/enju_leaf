require 'rails_helper'

describe "page/advanced_search" do
  fixtures :all

  context :login_with_admin do
    before(:each) do
      assign(:libraries, Library.all)
      view.stub(:current_user).and_return(User.friendly.find('enjuadmin'))
    end
    it "renders attributes in <p>" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      rendered.should match(/Advanced search/)
    end
  end
  context :guest do
    before(:each) do
      assign(:libraries, Library.all)
      view.stub(:current_user).and_return(nil)
    end
    it "renders attributes in <p>" do
      render
      # Run the generator again with the --webrat flag if you want to use webrat matchers
      rendered.should match(/Advanced search/)
    end
  end
end
