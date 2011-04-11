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

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested user as @user" do
        user = Factory.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should assign the requested user as @user" do
        user = Factory.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested user as @user" do
        user = Factory.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        user = Factory.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:user)
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created user as @user" do
          post :create, :user => @attrs
          assigns(:user).should be_valid
        end

        it "redirects to the created user" do
          post :create, :user => @attrs
          response.should redirect_to(user_url(assigns(:user)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @user" do
          post :create, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created user as @user" do
          post :create, :user => @attrs
          assigns(:user).should be_valid
        end

        it "redirects to the created user" do
          post :create, :user => @attrs
          response.should redirect_to(user_url(assigns(:user)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user as @user" do
          post :create, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user => @invalid_attrs
          response.should render_template("new")
        end
      end
    end
  end
end
