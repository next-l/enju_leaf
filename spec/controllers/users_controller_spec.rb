require 'spec_helper'

describe UsersController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all users as @users" do
        get :index
        assigns(:users).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all users as @users" do
        get :index
        assigns(:users).should_not be_empty
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all users as @users" do
        get :index
        assigns(:users).should be_empty
        response.should be_forbidden
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
        sign_in FactoryGirl.create(:admin)
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
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested user as @user" do
        get :new
        assigns(:user).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
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
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user as @user" do
        user = FactoryGirl.create(:user)
        get :edit, :id => user.id
        assigns(:user).should eq(user)
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:user)
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
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
        sign_in FactoryGirl.create(:librarian)
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

  describe "PUT update" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      @attrs = {:email => 'newaddress@example.jp', :locale => 'en'}
      @invalid_attrs = {:username => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(@user)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          assigns(:user).should eq(@user)
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @user, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
        end

        it "redirects to the user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
          response.should redirect_to(@user)
        end
      end

      describe "with invalid params" do
        it "assigns the user as @user" do
          put :update, :id => @user, :user => @invalid_attrs
          assigns(:user).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @user, :user => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @attrs
          assigns(:user).should eq(@user)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user" do
          put :update, :id => @user.id, :user => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @user.id, :user => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user as @user" do
          put :update, :id => @user.id, :user => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested user" do
        delete :destroy, :id => @user.id
      end

      it "redirects to the users list" do
        delete :destroy, :id => @user.id
        response.should redirect_to(users_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested user" do
        delete :destroy, :id => @user.id
      end

      it "redirects to the users list" do
        delete :destroy, :id => @user.id
        response.should redirect_to(users_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested user" do
        delete :destroy, :id => @user.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user" do
        delete :destroy, :id => @user.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
