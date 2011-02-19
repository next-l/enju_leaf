require 'spec_helper'

describe RequestTypesController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:request_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all request_types as @request_types" do
        get :index
        assigns(:request_types).should eq(RequestType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all request_types as @request_types" do
        get :index
        assigns(:request_types).should eq(RequestType.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign request_types as @request_types" do
        get :index
        assigns(:request_types).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign request_types as @request_types" do
        get :index
        assigns(:request_types).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :show, :id => request_type.id
        assigns(:request_type).should eq(request_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :show, :id => request_type.id
        assigns(:request_type).should eq(request_type)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :show, :id => request_type.id
        assigns(:request_type).should eq(request_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :show, :id => request_type.id
        assigns(:request_type).should eq(request_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested request_type as @request_type" do
        get :new
        assigns(:request_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested request_type as @request_type" do
        get :new
        assigns(:request_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested request_type as @request_type" do
        get :new
        assigns(:request_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested request_type as @request_type" do
        get :new
        assigns(:request_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :edit, :id => request_type.id
        assigns(:request_type).should eq(request_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :edit, :id => request_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :edit, :id => request_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested request_type as @request_type" do
        request_type = Factory.create(:request_type)
        get :edit, :id => request_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:request_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created request_type as @request_type" do
          post :create, :request_type => @attrs
          assigns(:request_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_type as @request_type" do
          post :create, :request_type => @invalid_attrs
          assigns(:request_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created request_type as @request_type" do
          post :create, :request_type => @attrs
          assigns(:request_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_type as @request_type" do
          post :create, :request_type => @invalid_attrs
          assigns(:request_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created request_type as @request_type" do
          post :create, :request_type => @attrs
          assigns(:request_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_type as @request_type" do
          post :create, :request_type => @invalid_attrs
          assigns(:request_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created request_type as @request_type" do
          post :create, :request_type => @attrs
          assigns(:request_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved request_type as @request_type" do
          post :create, :request_type => @invalid_attrs
          assigns(:request_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :request_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @request_type = Factory(:request_type)
      @attrs = Factory.attributes_for(:request_type)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
        end

        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
          assigns(:request_type).should eq(@request_type)
        end

        it "moves its position when specified" do
          put :update, :id => @request_type.id, :request_type => @attrs, :position => 2
          response.should redirect_to(request_types_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "updates the requested request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
        end

        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
          assigns(:request_type).should eq(@request_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
        end

        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
          assigns(:request_type).should eq(@request_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested request_type" do
          put :update, :id => @request_type.id, :request_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @request_type.id, :request_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested request_type as @request_type" do
          put :update, :id => @request_type.id, :request_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @request_type = Factory(:request_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested request_type" do
        delete :destroy, :id => @request_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested request_type" do
        delete :destroy, :id => @request_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested request_type" do
        delete :destroy, :id => @request_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested request_type" do
        delete :destroy, :id => @request_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @request_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
