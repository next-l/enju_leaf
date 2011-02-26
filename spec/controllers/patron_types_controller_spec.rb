require 'spec_helper'

describe PatronTypesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:patron_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all patron_types as @patron_types" do
        get :index
        assigns(:patron_types).should eq(PatronType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all patron_types as @patron_types" do
        get :index
        assigns(:patron_types).should eq(PatronType.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns empty as @patron_types" do
        get :index
        assigns(:patron_types).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns emptry as @patron_types" do
        get :index
        assigns(:patron_types).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :show, :id => patron_type.id
        assigns(:patron_type).should eq(patron_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :show, :id => patron_type.id
        assigns(:patron_type).should eq(patron_type)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :show, :id => patron_type.id
        assigns(:patron_type).should eq(patron_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :show, :id => patron_type.id
        assigns(:patron_type).should eq(patron_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_type as @patron_type" do
        get :new
        assigns(:patron_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested patron_type as @patron_type" do
        get :new
        assigns(:patron_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested patron_type as @patron_type" do
        get :new
        assigns(:patron_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_type as @patron_type" do
        get :new
        assigns(:patron_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :edit, :id => patron_type.id
        assigns(:patron_type).should eq(patron_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :edit, :id => patron_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :edit, :id => patron_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_type as @patron_type" do
        patron_type = Factory.create(:patron_type)
        get :edit, :id => patron_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:patron_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created patron_type as @patron_type" do
          post :create, :patron_type => @attrs
          assigns(:patron_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_type as @patron_type" do
          post :create, :patron_type => @invalid_attrs
          assigns(:patron_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created patron_type as @patron_type" do
          post :create, :patron_type => @attrs
          assigns(:patron_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_type as @patron_type" do
          post :create, :patron_type => @invalid_attrs
          assigns(:patron_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created patron_type as @patron_type" do
          post :create, :patron_type => @attrs
          assigns(:patron_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_type as @patron_type" do
          post :create, :patron_type => @invalid_attrs
          assigns(:patron_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created patron_type as @patron_type" do
          post :create, :patron_type => @attrs
          assigns(:patron_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved patron_type as @patron_type" do
          post :create, :patron_type => @invalid_attrs
          assigns(:patron_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :patron_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @patron_type = Factory(:patron_type)
      @attrs = Factory.attributes_for(:patron_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
        end

        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
          assigns(:patron_type).should eq(@patron_type)
        end

        it "moves its position when specified" do
          put :update, :id => @patron_type.id, :patron_type => @attrs, :position => 2
          response.should redirect_to(patron_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
        end

        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
          assigns(:patron_type).should eq(@patron_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
        end

        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
          assigns(:patron_type).should eq(@patron_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @patron_type.id, :patron_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested patron_type as @patron_type" do
          put :update, :id => @patron_type.id, :patron_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron_type = Factory(:patron_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested patron_type" do
        delete :destroy, :id => @patron_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested patron_type" do
        delete :destroy, :id => @patron_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested patron_type" do
        delete :destroy, :id => @patron_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron_type" do
        delete :destroy, :id => @patron_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
