require 'spec_helper'

describe SeriesStatementMergesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:series_statement_merge)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all series_statement_merges as @series_statement_merges" do
        get :index
        assigns(:series_statement_merges).should eq(SeriesStatementMerge.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all series_statement_merges as @series_statement_merges" do
        get :index
        assigns(:series_statement_merges).should eq(SeriesStatementMerge.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should be forbidden" do
        get :index
        assigns(:series_statement_merges).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be forbidden" do
        get :index
        assigns(:series_statement_merges).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :show, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :show, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :show, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end

    describe "When not logged in" do
      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :show, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        get :new
        assigns(:series_statement_merge).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        get :new
        assigns(:series_statement_merge).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested series_statement_merge as @series_statement_merge" do
        get :new
        assigns(:series_statement_merge).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_statement_merge as @series_statement_merge" do
        get :new
        assigns(:series_statement_merge).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :edit, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :edit, :id => series_statement_merge.id
        assigns(:series_statement_merge).should eq(series_statement_merge)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :edit, :id => series_statement_merge.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_statement_merge as @series_statement_merge" do
        series_statement_merge = FactoryGirl.create(:series_statement_merge)
        get :edit, :id => series_statement_merge.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:series_statement_merge)
      @invalid_attrs = {:series_statement_merge_list_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should be_valid
        end

        it "redirects to the created series_statement" do
          post :create, :series_statement_merge => @attrs
          response.should redirect_to(assigns(:series_statement_merge))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @invalid_attrs
          assigns(:series_statement_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_statement_merge => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should be_valid
        end

        it "redirects to the created series_statement" do
          post :create, :series_statement_merge => @attrs
          response.should redirect_to(assigns(:series_statement_merge))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @invalid_attrs
          assigns(:series_statement_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_statement_merge => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @invalid_attrs
          assigns(:series_statement_merge).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_statement_merge as @series_statement_merge" do
          post :create, :series_statement_merge => @invalid_attrs
          assigns(:series_statement_merge).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_statement_merge => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @series_statement_merge = FactoryGirl.create(:series_statement_merge)
      @attrs = FactoryGirl.attributes_for(:series_statement_merge)
      @invalid_attrs = {:series_statement_merge_list_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
        end

        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should eq(@series_statement_merge)
          response.should redirect_to(@series_statement_merge)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
        end

        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should eq(@series_statement_merge)
          response.should redirect_to(@series_statement_merge)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
        end

        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
          assigns(:series_statement_merge).should eq(@series_statement_merge)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_statement_merge as @series_statement_merge" do
          put :update, :id => @series_statement_merge.id, :series_statement_merge => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @series_statement_merge = FactoryGirl.create(:series_statement_merge)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested series_statement_merge" do
        delete :destroy, :id => @series_statement_merge.id
      end

      it "redirects to the series_statement_merges list" do
        delete :destroy, :id => @series_statement_merge.id
        response.should redirect_to(series_statement_merges_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested series_statement_merge" do
        delete :destroy, :id => @series_statement_merge.id
      end

      it "redirects to the series_statement_merges list" do
        delete :destroy, :id => @series_statement_merge.id
        response.should redirect_to(series_statement_merges_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested series_statement_merge" do
        delete :destroy, :id => @series_statement_merge.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_statement_merge.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested series_statement_merge" do
        delete :destroy, :id => @series_statement_merge.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_statement_merge.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
