require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe RequestStatusTypesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:request_status_type)
  end

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:request_status_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all request_status_types as @request_status_types" do
        get :index
        assigns(:request_status_types).should eq(RequestStatusType.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all request_status_types as @request_status_types" do
        get :index
        assigns(:request_status_types).should eq(RequestStatusType.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign request_status_types as @request_status_types" do
        get :index
        assigns(:request_status_types).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign request_status_types as @request_status_types" do
        get :index
        assigns(:request_status_types).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    before(:each) do
      @request_status_type = FactoryGirl.create(:request_status_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested request_status_type as @request_status_type" do
        get :show, :id => @request_status_type.id
        assigns(:request_status_type).should eq(@request_status_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested request_status_type as @request_status_type" do
        get :show, :id => @request_status_type.id
        assigns(:request_status_type).should eq(@request_status_type)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested request_status_type as @request_status_type" do
        get :show, :id => @request_status_type.id
        assigns(:request_status_type).should eq(@request_status_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested request_status_type as @request_status_type" do
        get :show, :id => @request_status_type.id
        assigns(:request_status_type).should eq(@request_status_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested request_status_type as @request_status_type" do
        get :new
        assigns(:request_status_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested request_status_type as @request_status_type" do
        get :new
        assigns(:request_status_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested request_status_type as @request_status_type" do
        get :new
        assigns(:request_status_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested request_status_type as @request_status_type" do
        get :new
        assigns(:request_status_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    before(:each) do
      @request_status_type = FactoryGirl.create(:request_status_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested request_status_type as @request_status_type" do
        get :edit, :id => @request_status_type.id
        assigns(:request_status_type).should eq(@request_status_type)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested request_status_type as @request_status_type" do
        get :edit, :id => @request_status_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested request_status_type as @request_status_type" do
        get :edit, :id => @request_status_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested request_status_type as @request_status_type" do
        get :edit, :id => @request_status_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created request_status_type as @request_status_type" do
          post :create, :request_status_type => @attrs
          assigns(:request_status_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_status_type as @request_status_type" do
          post :create, :request_status_type => @invalid_attrs
          assigns(:request_status_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created request_status_type as @request_status_type" do
          post :create, :request_status_type => @attrs
          assigns(:request_status_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_status_type as @request_status_type" do
          post :create, :request_status_type => @invalid_attrs
          assigns(:request_status_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created request_status_type as @request_status_type" do
          post :create, :request_status_type => @attrs
          assigns(:request_status_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_status_type as @request_status_type" do
          post :create, :request_status_type => @invalid_attrs
          assigns(:request_status_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created request_status_type as @request_status_type" do
          post :create, :request_status_type => @attrs
          assigns(:request_status_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_status_type as @request_status_type" do
          post :create, :request_status_type => @invalid_attrs
          assigns(:request_status_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_status_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @request_status_type = FactoryGirl.create(:request_status_type)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
        end

        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
          assigns(:request_status_type).should eq(@request_status_type)
        end

        it "moves its position when specified" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs, :move => 'lower'
          response.should redirect_to(request_status_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
        end

        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
          assigns(:request_status_type).should eq(@request_status_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
        end

        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
          assigns(:request_status_type).should eq(@request_status_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @request_status_type.id, :request_status_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_status_type as @request_status_type" do
          put :update, :id => @request_status_type.id, :request_status_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @request_status_type = FactoryGirl.create(:request_status_type)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested request_status_type" do
        delete :destroy, :id => @request_status_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_status_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested request_status_type" do
        delete :destroy, :id => @request_status_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_status_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested request_status_type" do
        delete :destroy, :id => @request_status_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_status_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested request_status_type" do
        delete :destroy, :id => @request_status_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_status_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
