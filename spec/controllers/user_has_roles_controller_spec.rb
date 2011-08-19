require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe UserHasRolesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all user_has_roles as @user_has_roles" do
        get :index
        assigns(:user_has_roles).should eq(UserHasRole.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns empty as @user_has_roles" do
        get :index
        assigns(:user_has_roles).should be_empty
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all user_has_roles as @user_has_roles" do
        get :index
        assigns(:user_has_roles).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all user_has_roles as @user_has_roles" do
        get :index
        assigns(:user_has_roles).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @user_has_role = user_has_roles(:admin)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user_has_role as @user_has_role" do
        get :show, :id => @user_has_role.id
        assigns(:user_has_role).should eq(@user_has_role)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested user_has_role as @user_has_role" do
        get :show, :id => @user_has_role.id
        assigns(:user_has_role).should eq(@user_has_role)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested user_has_role as @user_has_role" do
        get :show, :id => @user_has_role.id
        assigns(:user_has_role).should eq(@user_has_role)
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_has_role as @user_has_role" do
        get :show, :id => @user_has_role.id
        assigns(:user_has_role).should eq(@user_has_role)
      end
    end
  end
end
