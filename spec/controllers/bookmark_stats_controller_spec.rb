require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe BookmarkStatsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:bookmark_stat)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        assigns(:bookmark_stats).should eq(BookmarkStat.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        assigns(:bookmark_stats).should eq(BookmarkStat.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all bookmark_stats as @bookmark_stats" do
        get :index
        assigns(:bookmark_stats).should eq(BookmarkStat.all)
      end
    end

    describe "When not logged in" do
      it "should not assign bookmark_stats as @bookmark_stats" do
        get :index
        assigns(:bookmark_stats).should eq(BookmarkStat.all)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :show, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :show, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :show, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :show, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        get :new
        assigns(:bookmark_stat).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        get :new
        assigns(:bookmark_stat).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        get :new
        assigns(:bookmark_stat).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        get :new
        assigns(:bookmark_stat).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :edit, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :edit, :id => bookmark_stat.id
        assigns(:bookmark_stat).should eq(bookmark_stat)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :edit, :id => bookmark_stat.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat as @bookmark_stat" do
        bookmark_stat = FactoryGirl.create(:bookmark_stat)
        get :edit, :id => bookmark_stat.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:bookmark_stat)
      @invalid_attrs = {:start_date => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should be_valid
        end

        it "redirects to the created bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          response.should redirect_to(bookmark_stat_url(assigns(:bookmark_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @invalid_attrs
          assigns(:bookmark_stat).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :bookmark_stat => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should be_valid
        end

        it "redirects to the created bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          response.should redirect_to(bookmark_stat_url(assigns(:bookmark_stat)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @invalid_attrs
          assigns(:bookmark_stat).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :bookmark_stat => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @invalid_attrs
          assigns(:bookmark_stat).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat as @bookmark_stat" do
          post :create, :bookmark_stat => @invalid_attrs
          assigns(:bookmark_stat).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookmark_stat = FactoryGirl.create(:bookmark_stat)
      @attrs = FactoryGirl.attributes_for(:bookmark_stat)
      @invalid_attrs = {:start_date => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should eq(@bookmark_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should eq(@bookmark_stat)
          response.should redirect_to(@bookmark_stat)
        end
      end

      describe "with invalid params" do
        it "assigns the bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat, :bookmark_stat => @invalid_attrs
          assigns(:bookmark_stat).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @bookmark_stat, :bookmark_stat => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
        end

        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
          assigns(:bookmark_stat).should eq(@bookmark_stat)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat as @bookmark_stat" do
          put :update, :id => @bookmark_stat.id, :bookmark_stat => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @bookmark_stat = FactoryGirl.create(:bookmark_stat)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested bookmark_stat" do
        delete :destroy, :id => @bookmark_stat.id
      end

      it "redirects to the bookmark_stats list" do
        delete :destroy, :id => @bookmark_stat.id
        response.should redirect_to(bookmark_stats_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested bookmark_stat" do
        delete :destroy, :id => @bookmark_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark_stat.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested bookmark_stat" do
        delete :destroy, :id => @bookmark_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark_stat.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookmark_stat" do
        delete :destroy, :id => @bookmark_stat.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark_stat.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
