require 'spec_helper'

describe CheckoutStatHasUsersController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:checkout_stat_has_user)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all checkout_stat_has_users as @checkout_stat_has_users" do
        get :index
        assigns(:checkout_stat_has_users).should eq(CheckoutStatHasUser.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all checkout_stat_has_users as @checkout_stat_has_users" do
        get :index
        assigns(:checkout_stat_has_users).should eq(CheckoutStatHasUser.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all checkout_stat_has_users as @checkout_stat_has_users" do
        get :index
        assigns(:checkout_stat_has_users).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all checkout_stat_has_users as @checkout_stat_has_users" do
        get :index
        assigns(:checkout_stat_has_users).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :show, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :show, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :show, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end

    describe "When not logged in" do
      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :show, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        get :new
        assigns(:checkout_stat_has_user).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested checkout_stat_has_user as @checkout_stat_has_user" do
        get :new
        assigns(:checkout_stat_has_user).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested checkout_stat_has_user as @checkout_stat_has_user" do
        get :new
        assigns(:checkout_stat_has_user).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checkout_stat_has_user as @checkout_stat_has_user" do
        get :new
        assigns(:checkout_stat_has_user).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :edit, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :edit, :id => checkout_stat_has_user.id
        assigns(:checkout_stat_has_user).should eq(checkout_stat_has_user)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :edit, :id => checkout_stat_has_user.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checkout_stat_has_user as @checkout_stat_has_user" do
        checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
        get :edit, :id => checkout_stat_has_user.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:checkout_stat_has_user)
      @invalid_attrs = {:user_checkout_stat_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :checkout_stat_has_user => @attrs
          response.should redirect_to(assigns(:checkout_stat_has_user))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          assigns(:checkout_stat_has_user).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          assigns(:checkout_stat_has_user).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          assigns(:checkout_stat_has_user).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved checkout_stat_has_user as @checkout_stat_has_user" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          assigns(:checkout_stat_has_user).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :checkout_stat_has_user => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
      @attrs = FactoryGirl.attributes_for(:checkout_stat_has_user)
      @invalid_attrs = {:user_checkout_stat_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
        end

        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should eq(@checkout_stat_has_user)
          response.should redirect_to(@checkout_stat_has_user)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @invalid_attrs
          assigns(:checkout_stat_has_user).should eq(@checkout_stat_has_user)
        end

        it "should be forbidden" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
          assigns(:checkout_stat_has_user).should eq(@checkout_stat_has_user)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout_stat_has_user as @checkout_stat_has_user" do
          put :update, :id => @checkout_stat_has_user.id, :checkout_stat_has_user => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @checkout_stat_has_user = FactoryGirl.create(:checkout_stat_has_user)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested checkout_stat_has_user" do
        delete :destroy, :id => @checkout_stat_has_user.id
      end

      it "redirects to the checkout_stat_has_users list" do
        delete :destroy, :id => @checkout_stat_has_user.id
        response.should redirect_to(checkout_stat_has_users_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested checkout_stat_has_user" do
        delete :destroy, :id => @checkout_stat_has_user.id
      end

      it "redirects to the checkout_stat_has_users list" do
        delete :destroy, :id => @checkout_stat_has_user.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested checkout_stat_has_user" do
        delete :destroy, :id => @checkout_stat_has_user.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkout_stat_has_user.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested checkout_stat_has_user" do
        delete :destroy, :id => @checkout_stat_has_user.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkout_stat_has_user.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
