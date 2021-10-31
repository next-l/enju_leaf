require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ParticipatesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:participate)
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all participates as @participates" do
        get :index
        assigns(:participates).should eq(Participate.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all participates as @participates" do
        get :index
        assigns(:participates).should eq(Participate.page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @participates" do
        get :index
        assigns(:participates).should be_nil
      end
    end

    describe "When not logged in" do
      it "assigns empty as @participates" do
        get :index
        assigns(:participates).should be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :show, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :show, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :show, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end

    describe "When not logged in" do
      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :show, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested participate as @participate" do
        get :new
        assigns(:participate).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested participate as @participate" do
        get :new
        assigns(:participate).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested participate as @participate" do
        get :new
        assigns(:participate).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :edit, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :edit, params: { id: participate.id }
        assigns(:participate).should eq(participate)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :edit, params: { id: participate.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested participate as @participate" do
        participate = FactoryBot.create(:participate)
        get :edit, params: { id: participate.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {event_id: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, params: { participate: @attrs }
          assigns(:participate).should be_valid
        end

        it "redirects to the created participate" do
          post :create, params: { participate: @attrs }
          response.should redirect_to(participate_url(assigns(:participate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, params: { participate: @invalid_attrs }
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { participate: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, params: { participate: @attrs }
          assigns(:participate).should be_valid
        end

        it "redirects to the created participate" do
          post :create, params: { participate: @attrs }
          response.should redirect_to(participate_url(assigns(:participate)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, params: { participate: @invalid_attrs }
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { participate: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, params: { participate: @attrs }
          assigns(:participate).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { participate: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, params: { participate: @invalid_attrs }
          assigns(:participate).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { participate: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created participate as @participate" do
          post :create, params: { participate: @attrs }
          assigns(:participate).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { participate: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved participate as @participate" do
          post :create, params: { participate: @invalid_attrs }
          assigns(:participate).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { participate: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @participate = FactoryBot.create(:participate)
      @attrs = valid_attributes
      @invalid_attrs = {event_id: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
        end

        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
          assigns(:participate).should eq(@participate)
          response.should redirect_to(@participate)
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
        end

        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
          assigns(:participate).should eq(@participate)
          response.should redirect_to(@participate)
        end
      end

      describe "with invalid params" do
        it "assigns the participate as @participate" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
          assigns(:participate).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
        end

        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
          assigns(:participate).should eq(@participate)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested participate" do
          put :update, params: { id: @participate.id, participate: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @participate.id, participate: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested participate as @participate" do
          put :update, params: { id: @participate.id, participate: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @participate = FactoryBot.create(:participate)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested participate" do
        delete :destroy, params: { id: @participate.id }
      end

      it "redirects to the participates list" do
        delete :destroy, params: { id: @participate.id }
        response.should redirect_to(participates_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested participate" do
        delete :destroy, params: { id: @participate.id }
      end

      it "redirects to the participates list" do
        delete :destroy, params: { id: @participate.id }
        response.should redirect_to(participates_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested participate" do
        delete :destroy, params: { id: @participate.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @participate.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested participate" do
        delete :destroy, params: { id: @participate.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @participate.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
