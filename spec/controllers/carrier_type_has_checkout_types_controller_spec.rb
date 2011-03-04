require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe CarrierTypeHasCheckoutTypesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      Factory.create(:carrier_type_has_checkout_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all carrier_type_has_checkout_types as @carrier_type_has_checkout_types" do
        get :index
        assigns(:carrier_type_has_checkout_types).should eq(CarrierTypeHasCheckoutType.all)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all carrier_type_has_checkout_types as @carrier_type_has_checkout_types" do
        get :index
        assigns(:carrier_type_has_checkout_types).should eq(CarrierTypeHasCheckoutType.all)
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all carrier_type_has_checkout_types as @carrier_type_has_checkout_types" do
        get :index
        assigns(:carrier_type_has_checkout_types).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all carrier_type_has_checkout_types as @carrier_type_has_checkout_types" do
        get :index
        assigns(:carrier_type_has_checkout_types).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :show, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :show, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :show, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end

    describe "When not logged in" do
      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :show, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        get :new
        assigns(:carrier_type_has_checkout_type).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        get :new
        assigns(:carrier_type_has_checkout_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        get :new
        assigns(:carrier_type_has_checkout_type).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        get :new
        assigns(:carrier_type_has_checkout_type).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :edit, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :edit, :id => carrier_type_has_checkout_type.id
        assigns(:carrier_type_has_checkout_type).should eq(carrier_type_has_checkout_type)
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :edit, :id => carrier_type_has_checkout_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
        carrier_type_has_checkout_type = Factory.create(:carrier_type_has_checkout_type)
        get :edit, :id => carrier_type_has_checkout_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = Factory.attributes_for(:carrier_type_has_checkout_type)
      @invalid_attrs = {:carrier_type_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :carrier_type_has_checkout_type => @attrs
          response.should redirect_to(assigns(:carrier_type_has_checkout_type))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          assigns(:carrier_type_has_checkout_type).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          assigns(:carrier_type_has_checkout_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "assigns a newly created carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          assigns(:carrier_type_has_checkout_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          assigns(:carrier_type_has_checkout_type).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :carrier_type_has_checkout_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @carrier_type_has_checkout_type = Factory(:carrier_type_has_checkout_type)
      @attrs = Factory.attributes_for(:carrier_type_has_checkout_type)
      @invalid_attrs = {:carrier_type_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "updates the requested carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
        end

        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should eq(@carrier_type_has_checkout_type)
          response.should redirect_to(@carrier_type_has_checkout_type)
        end
      end

      describe "with invalid params" do
        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @invalid_attrs
          assigns(:carrier_type_has_checkout_type).should eq(@carrier_type_has_checkout_type)
        end

        it "should be forbidden" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      describe "with valid params" do
        it "updates the requested carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
          assigns(:carrier_type_has_checkout_type).should eq(@carrier_type_has_checkout_type)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested carrier_type_has_checkout_type as @carrier_type_has_checkout_type" do
          put :update, :id => @carrier_type_has_checkout_type.id, :carrier_type_has_checkout_type => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @carrier_type_has_checkout_type = Factory(:carrier_type_has_checkout_type)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested carrier_type_has_checkout_type" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
      end

      it "redirects to the carrier_type_has_checkout_types list" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
        response.should redirect_to(carrier_type_has_checkout_types_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested carrier_type_has_checkout_type" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
      end

      it "redirects to the carrier_type_has_checkout_types list" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Subject" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested carrier_type_has_checkout_type" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested carrier_type_has_checkout_type" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @carrier_type_has_checkout_type.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
