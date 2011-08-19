require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe UserReserveStatsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:user_reserve_stat)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all user_reserve_stats as @user_reserve_stats" do
        get :index
        assigns(:user_reserve_stats).should eq(UserReserveStat.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all user_reserve_stats as @user_reserve_stats" do
        get :index
        assigns(:user_reserve_stats).should eq(UserReserveStat.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all user_reserve_stats as @user_reserve_stats" do
        get :index
        assigns(:user_reserve_stats).should eq(UserReserveStat.all)
      end
    end

    describe "When not logged in" do
      it "should not assign user_reserve_stats as @user_reserve_stats" do
        get :index
        assigns(:user_reserve_stats).should eq(UserReserveStat.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :show, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :show, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :show, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :show, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        get :new
        assigns(:user_reserve_stat).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        get :new
        assigns(:user_reserve_stat).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested user_reserve_stat as @user_reserve_stat" do
        get :new
        assigns(:user_reserve_stat).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_reserve_stat as @user_reserve_stat" do
        get :new
        assigns(:user_reserve_stat).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :edit, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :edit, :id => user_reserve_stat.id
        assigns(:user_reserve_stat).should eq(user_reserve_stat)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :edit, :id => user_reserve_stat.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_reserve_stat as @user_reserve_stat" do
        user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
        get :edit, :id => user_reserve_stat.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:user_reserve_stat)
      @invalid_attrs = {:start_date => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should be_valid
        end

        it "redirects to the created user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          response.should redirect_to(user_reserve_stat_url(assigns(:user_reserve_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @invalid_attrs
          assigns(:user_reserve_stat).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user_reserve_stat => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should be_valid
        end

        it "redirects to the created user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          response.should redirect_to(user_reserve_stat_url(assigns(:user_reserve_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @invalid_attrs
          assigns(:user_reserve_stat).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :user_reserve_stat => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should be_valid
        end

        it "should be forbidden" do
          post :create, :user_reserve_stat => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @invalid_attrs
          assigns(:user_reserve_stat).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :user_reserve_stat => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should be_valid
        end

        it "should be forbidden" do
          post :create, :user_reserve_stat => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved user_reserve_stat as @user_reserve_stat" do
          post :create, :user_reserve_stat => @invalid_attrs
          assigns(:user_reserve_stat).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :user_reserve_stat => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
      @attrs = FactoryGirl.attributes_for(:user_reserve_stat)
      @invalid_attrs = {:start_date => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
        end

        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should eq(@user_reserve_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
        end

        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should eq(@user_reserve_stat)
          response.should redirect_to(@user_reserve_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat, :user_reserve_stat => @invalid_attrs
          assigns(:user_reserve_stat).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @user_reserve_stat, :user_reserve_stat => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
        end

        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
          assigns(:user_reserve_stat).should eq(@user_reserve_stat)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested user_reserve_stat as @user_reserve_stat" do
          put :update, :id => @user_reserve_stat.id, :user_reserve_stat => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user_reserve_stat = FactoryGirl.create(:user_reserve_stat)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested user_reserve_stat" do
        delete :destroy, :id => @user_reserve_stat.id
      end

      it "redirects to the user_reserve_stats list" do
        delete :destroy, :id => @user_reserve_stat.id
        response.should redirect_to(user_reserve_stats_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested user_reserve_stat" do
        delete :destroy, :id => @user_reserve_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_reserve_stat.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested user_reserve_stat" do
        delete :destroy, :id => @user_reserve_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_reserve_stat.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_reserve_stat" do
        delete :destroy, :id => @user_reserve_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_reserve_stat.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
