require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SeriesHasManifestationsController do
  fixtures :series_has_manifestations
  disconnect_sunspot

  def mock_series_has_manifestation(stubs={})
    @mock_series_has_manifestation ||= mock_model(SeriesHasManifestation, stubs).as_null_object
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all series_has_manifestations as @series_has_manifestations" do
        get :index
        assigns(:series_has_manifestations).should eq(SeriesHasManifestation.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all series_has_manifestations as @series_has_manifestations" do
        get :index
        assigns(:series_has_manifestations).should eq(SeriesHasManifestation.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all series_has_manifestations as @series_has_manifestations" do
        get :index
        assigns(:series_has_manifestations).should eq(SeriesHasManifestation.page(1))
      end
    end

    describe "When not logged in" do
      it "assigns all series_has_manifestations as @series_has_manifestations" do
        get :index
        assigns(:series_has_manifestations).should eq(SeriesHasManifestation.page(1))
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :show, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :show, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :show, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end

    describe "When not logged in" do
      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :show, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        get :new
        assigns(:series_has_manifestation).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        get :new
        assigns(:series_has_manifestation).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested series_has_manifestation as @series_has_manifestation" do
        get :new
        assigns(:series_has_manifestation).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_has_manifestation as @series_has_manifestation" do
        get :new
        assigns(:series_has_manifestation).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :edit, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :edit, :id => series_has_manifestation.id
        assigns(:series_has_manifestation).should eq(series_has_manifestation)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :edit, :id => series_has_manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested series_has_manifestation as @series_has_manifestation" do
        series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
        get :edit, :id => series_has_manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:series_has_manifestation)
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should be_valid
        end

        it "redirects to the created series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          response.should redirect_to(series_has_manifestation_url(assigns(:series_has_manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @invalid_attrs
          assigns(:series_has_manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_has_manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should be_valid
        end

        it "redirects to the created series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          response.should redirect_to(series_has_manifestation_url(assigns(:series_has_manifestation)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @invalid_attrs
          assigns(:series_has_manifestation).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :series_has_manifestation => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_has_manifestation => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @invalid_attrs
          assigns(:series_has_manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should be_valid
        end

        it "should be forbidden" do
          post :create, :series_has_manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved series_has_manifestation as @series_has_manifestation" do
          post :create, :series_has_manifestation => @invalid_attrs
          assigns(:series_has_manifestation).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :series_has_manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
      @attrs = FactoryGirl.attributes_for(:series_has_manifestation)
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
        end

        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should eq(@series_has_manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
        end

        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should eq(@series_has_manifestation)
          response.should redirect_to(@series_has_manifestation)
        end
      end

      describe "with invalid params" do
        it "assigns the series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation, :series_has_manifestation => @invalid_attrs
          assigns(:series_has_manifestation).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @series_has_manifestation, :series_has_manifestation => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
        end

        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
          assigns(:series_has_manifestation).should eq(@series_has_manifestation)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested series_has_manifestation as @series_has_manifestation" do
          put :update, :id => @series_has_manifestation.id, :series_has_manifestation => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @series_has_manifestation = FactoryGirl.create(:series_has_manifestation)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested series_has_manifestation" do
        delete :destroy, :id => @series_has_manifestation.id
      end

      it "redirects to the series_has_manifestations list" do
        delete :destroy, :id => @series_has_manifestation.id
        response.should redirect_to(series_has_manifestations_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested series_has_manifestation" do
        delete :destroy, :id => @series_has_manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_has_manifestation.id
        response.should redirect_to(series_has_manifestations_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested series_has_manifestation" do
        delete :destroy, :id => @series_has_manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_has_manifestation.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested series_has_manifestation" do
        delete :destroy, :id => @series_has_manifestation.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @series_has_manifestation.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
