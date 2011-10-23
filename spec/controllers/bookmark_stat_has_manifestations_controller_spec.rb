require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe BookmarkStatHasManifestationsController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:bookmark_stat_has_manifestation)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all bookmark_stat_has_manifestations as @bookmark_stat_has_manifestations" do
        get :index
        assigns(:bookmark_stat_has_manifestations).should eq(BookmarkStatHasManifestation.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all bookmark_stat_has_manifestations as @bookmark_stat_has_manifestations" do
        get :index
        assigns(:bookmark_stat_has_manifestations).should eq(BookmarkStatHasManifestation.all)
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      it "assigns all bookmark_stat_has_manifestations as @bookmark_stat_has_manifestations" do
        get :index
        assigns(:bookmark_stat_has_manifestations).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all bookmark_stat_has_manifestations as @bookmark_stat_has_manifestations" do
        get :index
        assigns(:bookmark_stat_has_manifestations).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :show, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :show, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :show, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end

    describe "When not logged in" do
      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :show, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        get :new
        assigns(:bookmark_stat_has_manifestation).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        get :new
        assigns(:bookmark_stat_has_manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      it "should not assign the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        get :new
        assigns(:bookmark_stat_has_manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        get :new
        assigns(:bookmark_stat_has_manifestation).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :edit, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :edit, :id => bookmark_stat_has_manifestation.id
        assigns(:bookmark_stat_has_manifestation).should eq(bookmark_stat_has_manifestation)
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :edit, :id => bookmark_stat_has_manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
        bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
        get :edit, :id => bookmark_stat_has_manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:bookmark_stat_has_manifestation)
      @invalid_attrs = {:bookmark_stat_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          response.should redirect_to(assigns(:bookmark_stat_has_manifestation))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          assigns(:bookmark_stat_has_manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          assigns(:bookmark_stat_has_manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      describe "with valid params" do
        it "assigns a newly created bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          assigns(:bookmark_stat_has_manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          assigns(:bookmark_stat_has_manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
      @attrs = FactoryGirl.attributes_for(:bookmark_stat_has_manifestation)
      @invalid_attrs = {:bookmark_stat_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
        end

        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should eq(@bookmark_stat_has_manifestation)
          response.should redirect_to(@bookmark_stat_has_manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @invalid_attrs
          assigns(:bookmark_stat_has_manifestation).should eq(@bookmark_stat_has_manifestation)
        end

        it "should be forbidden" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      describe "with valid params" do
        it "updates the requested bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
          assigns(:bookmark_stat_has_manifestation).should eq(@bookmark_stat_has_manifestation)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested bookmark_stat_has_manifestation as @bookmark_stat_has_manifestation" do
          put :update, :id => @bookmark_stat_has_manifestation.id, :bookmark_stat_has_manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @bookmark_stat_has_manifestation = FactoryGirl.create(:bookmark_stat_has_manifestation)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested bookmark_stat_has_manifestation" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
      end

      it "redirects to the bookmark_stat_has_manifestations list" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
        response.should redirect_to(bookmark_stat_has_manifestations_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested bookmark_stat_has_manifestation" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
      end

      it "redirects to the bookmark_stat_has_manifestations list" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Manifestation" do
      login_user

      it "destroys the requested bookmark_stat_has_manifestation" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested bookmark_stat_has_manifestation" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @bookmark_stat_has_manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
