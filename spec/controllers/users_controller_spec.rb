require 'spec_helper'

describe UsersController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all users as @users" do
        get :index
        assigns(:users).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all users as @users" do
        get :index
        assigns(:users).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should eq(User.find('admin'))
      end
    end

    describe "When not logged in" do
      it "assigns the requested user as @user" do
        get :show, :id => 'admin'
        assigns(:user).should eq(User.find('admin'))
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
