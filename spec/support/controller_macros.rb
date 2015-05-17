module ControllerMacros
  def login_admin
    before(:each) do
      controller.stub(:current_user) { FactoryGirl.create(:admin) }
    end
  end

  def login_librarian
    before(:each) do
      controller.stub(:current_user) { FactoryGirl.create(:librarian) }
    end
  end

  def login_user
    before(:each) do
      controller.stub(:current_user) { FactoryGirl.create(:user) }
    end
  end

  def login_fixture_admin
    before(:each) do
      @user = users(:admin)
      controller.stub(:current_user) { @user }
    end
  end

  def login_fixture_librarian
    before(:each) do
      @user = users(:librarian1)
      controller.stub(:current_user) { @user }
    end
  end

  def login_fixture_user
    before(:each) do
      @user = users(:user1)
      controller.stub(:current_user) { @user }
    end
  end
end
