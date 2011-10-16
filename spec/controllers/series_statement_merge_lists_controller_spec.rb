require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SeriesStatementMergeListsController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all series_statement_merge_lists as @series_statement_merge_lists" do
        get :index
        assigns(:series_statement_merge_lists).should eq(SeriesStatementMergeList.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all series_statement_merge_lists as @series_statement_merge_lists" do
        get :index
        assigns(:series_statement_merge_lists).should eq(SeriesStatementMergeList.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns empty as @series_statement_merge_lists" do
        get :index
        assigns(:series_statement_merge_lists).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns empty as @series_statement_merge_lists" do
        get :index
        assigns(:series_statement_merge_lists).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :show, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :show, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :show, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end

    describe "When not logged in" do
      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :show, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        get :new
        assigns(:series_statement_merge_list).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        get :new
        assigns(:series_statement_merge_list).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested series_statement_merge_list as @series_statement_merge_list" do
        get :new
        assigns(:series_statement_merge_list).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_statement_merge_list as @series_statement_merge_list" do
        get :new
        assigns(:series_statement_merge_list).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :edit, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :edit, :id => series_statement_merge_list.id
        assigns(:series_statement_merge_list).should eq(series_statement_merge_list)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :edit, :id => series_statement_merge_list.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_statement_merge_list as @series_statement_merge_list" do
        series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
        get :edit, :id => series_statement_merge_list.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:series_statement_merge_list)
      @invalid_attrs = {:title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should be_valid
        end

        it "redirects to the created series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          response.should redirect_to(series_statement_merge_list_url(assigns(:series_statement_merge_list)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @invalid_attrs
          assigns(:series_statement_merge_list).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_statement_merge_list => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should be_valid
        end

        it "redirects to the created series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          response.should redirect_to(series_statement_merge_list_url(assigns(:series_statement_merge_list)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @invalid_attrs
          assigns(:series_statement_merge_list).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_statement_merge_list => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge_list => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @invalid_attrs
          assigns(:series_statement_merge_list).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge_list => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge_list => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge_list as @series_statement_merge_list" do
          post :create, :series_statement_merge_list => @invalid_attrs
          assigns(:series_statement_merge_list).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge_list => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
      @attrs = FactoryGirl.attributes_for(:series_statement_merge_list)
      @invalid_attrs = {:title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
        end

        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should eq(@series_statement_merge_list)
          response.should redirect_to(@series_statement_merge_list)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
        end

        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should eq(@series_statement_merge_list)
          response.should redirect_to(@series_statement_merge_list)
        end
      end

      describe "with invalid params" do
        it "assigns the series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
          assigns(:series_statement_merge_list).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
        end

        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
          assigns(:series_statement_merge_list).should eq(@series_statement_merge_list)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge_list as @series_statement_merge_list" do
          put :update, :id => @series_statement_merge_list.id, :series_statement_merge_list => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @series_statement_merge_list = FactoryGirl.create(:series_statement_merge_list)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested series_statement_merge_list" do
        delete :destroy, :id => @series_statement_merge_list.id
      end

      it "redirects to the series_statement_merge_lists list" do
        delete :destroy, :id => @series_statement_merge_list.id
        response.should redirect_to(series_statement_merge_lists_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested series_statement_merge_list" do
        delete :destroy, :id => @series_statement_merge_list.id
      end

      it "redirects to the series_statement_merge_lists list" do
        delete :destroy, :id => @series_statement_merge_list.id
        response.should redirect_to(series_statement_merge_lists_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested series_statement_merge_list" do
        delete :destroy, :id => @series_statement_merge_list.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_statement_merge_list.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested series_statement_merge_list" do
        delete :destroy, :id => @series_statement_merge_list.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_statement_merge_list.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
