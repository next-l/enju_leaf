module ControllerMacros
  def login_admin
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in Factory.create(:admin)
    end
  end

  def login_librarian
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = Factory.create(:librarian)
      sign_in user
    end
  end

  def login_user
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      user = Factory.create(:user)
      sign_in user
    end
  end
end
