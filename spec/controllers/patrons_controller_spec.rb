require 'spec_helper'

describe PatronsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all patrons as @patrons" do
        get :index
        assigns(:patrons).should_not be_empty
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron as @patron" do
        get :show, :id => @patron.id
        assigns(:patron).should eq(@patron)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron as @patron" do
        get :new
        assigns(:patron).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        assigns(:patron).should eq(patron)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        assigns(:patron).should eq(patron)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron as @patron" do
        patron = Patron.find(1)
        get :edit, :id => patron.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:patron)
      @invalid_attrs = FactoryGirl.attributes_for(:patron, :full_name => '')
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron => @attrs
          response.should redirect_to(patron_url(assigns(:patron)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :patron => @attrs
          response.should redirect_to(patron_url(assigns(:patron)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :patron => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created patron as @patron" do
          post :create, :patron => @attrs
          assigns(:patron).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron as @patron" do
          post :create, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
      @attrs = FactoryGirl.attributes_for(:patron)
      @invalid_attrs = FactoryGirl.attributes_for(:patron, :full_name => '')
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
          response.should redirect_to(@patron)
        end
      end

      describe "with invalid params" do
        it "assigns the patron as @patron" do
          put :update, :id => @patron, :patron => @invalid_attrs
          assigns(:patron).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @patron, :patron => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @attrs
          assigns(:patron).should eq(@patron)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested patron" do
          put :update, :id => @patron.id, :patron => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @patron.id, :patron => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron as @patron" do
          put :update, :id => @patron.id, :patron => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron = FactoryGirl.create(:patron)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "redirects to the patrons list" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(patrons_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "redirects to the patrons list" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(patrons_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron" do
        delete :destroy, :id => @patron.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
