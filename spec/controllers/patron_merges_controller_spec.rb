require 'spec_helper'

describe PatronMergesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:patron_merge)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all patron_merges as @patron_merges" do
        get :index
        assigns(:patron_merges).should eq(PatronMerge.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all patron_merges as @patron_merges" do
        get :index
        assigns(:patron_merges).should eq(PatronMerge.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "should be forbidden" do
        get :index
        assigns(:patron_merges).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be forbidden" do
        get :index
        assigns(:patron_merges).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :show, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :show, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :show, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :show, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested patron_merge as @patron_merge" do
        get :new
        assigns(:patron_merge).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested patron_merge as @patron_merge" do
        get :new
        assigns(:patron_merge).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested patron_merge as @patron_merge" do
        get :new
        assigns(:patron_merge).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_merge as @patron_merge" do
        get :new
        assigns(:patron_merge).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :edit, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :edit, :id => patron_merge.id
        assigns(:patron_merge).should eq(patron_merge)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :edit, :id => patron_merge.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_merge as @patron_merge" do
        patron_merge = FactoryGirl.create(:patron_merge)
        get :edit, :id => patron_merge.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:patron_merge)
      @invalid_attrs = {:patron_merge_list_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created patron_merge as @patron_merge" do
          post :create, :patron_merge => @attrs
          assigns(:patron_merge).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron_merge => @attrs
          response.should redirect_to(assigns(:patron_merge))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_merge as @patron_merge" do
          post :create, :patron_merge => @invalid_attrs
          assigns(:patron_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron_merge => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created patron_merge as @patron_merge" do
          post :create, :patron_merge => @attrs
          assigns(:patron_merge).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron_merge => @attrs
          response.should redirect_to(assigns(:patron_merge))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_merge as @patron_merge" do
          post :create, :patron_merge => @invalid_attrs
          assigns(:patron_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron_merge => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created patron_merge as @patron_merge" do
          post :create, :patron_merge => @attrs
          assigns(:patron_merge).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_merge => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_merge as @patron_merge" do
          post :create, :patron_merge => @invalid_attrs
          assigns(:patron_merge).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_merge => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created patron_merge as @patron_merge" do
          post :create, :patron_merge => @attrs
          assigns(:patron_merge).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_merge => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_merge as @patron_merge" do
          post :create, :patron_merge => @invalid_attrs
          assigns(:patron_merge).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_merge => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @patron_merge = FactoryGirl.create(:patron_merge)
      @attrs = FactoryGirl.attributes_for(:patron_merge)
      @invalid_attrs = {:patron_merge_list_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
        end

        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
          assigns(:patron_merge).should eq(@patron_merge)
          response.should redirect_to(@patron_merge)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
        end

        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
          assigns(:patron_merge).should eq(@patron_merge)
          response.should redirect_to(@patron_merge)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
        end

        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
          assigns(:patron_merge).should eq(@patron_merge)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @patron_merge.id, :patron_merge => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_merge as @patron_merge" do
          put :update, :id => @patron_merge.id, :patron_merge => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron_merge = FactoryGirl.create(:patron_merge)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested patron_merge" do
        delete :destroy, :id => @patron_merge.id
      end

      it "redirects to the patron_merges list" do
        delete :destroy, :id => @patron_merge.id
        response.should redirect_to(patron_merges_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested patron_merge" do
        delete :destroy, :id => @patron_merge.id
      end

      it "redirects to the patron_merges list" do
        delete :destroy, :id => @patron_merge.id
        response.should redirect_to(patron_merges_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested patron_merge" do
        delete :destroy, :id => @patron_merge.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_merge.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron_merge" do
        delete :destroy, :id => @patron_merge.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_merge.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
