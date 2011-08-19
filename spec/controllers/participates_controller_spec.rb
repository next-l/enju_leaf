require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ParticipatesController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all participates as @participates" do
        get :index
        assigns(:participates).should eq(Participate.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all participates as @participates" do
        get :index
        assigns(:participates).should eq(Participate.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns empty as @participates" do
        get :index
        assigns(:participates).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns empty as @participates" do
        get :index
        assigns(:participates).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :show, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :show, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :show, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end

    describe "When not logged in" do
      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :show, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :edit, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :edit, :id => participate.id
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :edit, :id => participate.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested participate as @participate" do
        participate = FactoryGirl.create(:participate)
        get :edit, :id => participate.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:participate)
      @invalid_attrs = {:event_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, :participate => @attrs
          assigns(:participate).should be_valid
        end

        it "redirects to the created participate" do
          post :create, :participate => @attrs
          response.should redirect_to(participate_url(assigns(:participate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, :participate => @invalid_attrs
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :participate => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, :participate => @attrs
          assigns(:participate).should be_valid
        end

        it "redirects to the created participate" do
          post :create, :participate => @attrs
          response.should redirect_to(participate_url(assigns(:participate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, :participate => @invalid_attrs
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :participate => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, :participate => @attrs
          assigns(:participate).should be_valid
        end

        it "should be forbidden" do
          post :create, :participate => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, :participate => @invalid_attrs
          assigns(:participate).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :participate => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, :participate => @attrs
          assigns(:participate).should be_valid
        end

        it "should be forbidden" do
          post :create, :participate => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, :participate => @invalid_attrs
          assigns(:participate).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :participate => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @participate = FactoryGirl.create(:participate)
      @attrs = FactoryGirl.attributes_for(:participate)
      @invalid_attrs = {:event_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, :id => @participate.id, :participate => @attrs
        end

        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @attrs
          assigns(:participate).should eq(@participate)
          response.should redirect_to(@participate)
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, :id => @participate.id, :participate => @attrs
        end

        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @attrs
          assigns(:participate).should eq(@participate)
          response.should redirect_to(@participate)
        end
      end

      describe "with invalid params" do
        it "assigns the participate as @participate" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, :id => @participate.id, :participate => @attrs
        end

        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @attrs
          assigns(:participate).should eq(@participate)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested participate" do
          put :update, :id => @participate.id, :participate => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @participate.id, :participate => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, :id => @participate.id, :participate => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @participate = FactoryGirl.create(:participate)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested participate" do
        delete :destroy, :id => @participate.id
      end

      it "redirects to the participates list" do
        delete :destroy, :id => @participate.id
        response.should redirect_to(participates_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested participate" do
        delete :destroy, :id => @participate.id
      end

      it "redirects to the participates list" do
        delete :destroy, :id => @participate.id
        response.should redirect_to(participates_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested participate" do
        delete :destroy, :id => @participate.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @participate.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested participate" do
        delete :destroy, :id => @participate.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @participate.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
