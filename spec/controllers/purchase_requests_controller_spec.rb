require 'spec_helper'

describe PurchaseRequestsController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all purchase_requests as @purchase_requests" do
        get :index
        assigns(:purchase_requests).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all purchase_requests as @purchase_requests" do
        get :index
        assigns(:purchase_requests).should_not be_empty
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all purchase_requests as @purchase_requests" do
        get :index
        assigns(:purchase_requests).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all purchase_requests as @purchase_requests" do
        get :index
        assigns(:purchase_requests).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = FactoryGirl.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = FactoryGirl.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = FactoryGirl.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When not logged in" do
      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = FactoryGirl.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      #@purchase_request = purchase_requests(:purchase_request_00001)
      @purchase_request = FactoryGirl.create(:purchase_request)
      @attrs = FactoryGirl.attributes_for(:purchase_request)
      @invalid_attrs = {:title => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin)
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
        end

        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
          assigns(:purchase_request).should eq(@purchase_request)
          response.should redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request)
        end
      end

      describe "with invalid params" do
        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
        end

        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
          assigns(:purchase_request).should eq(@purchase_request)
          response.should redirect_to user_purchase_request_url(@purchase_request.user, @purchase_request)
        end
      end

      describe "with invalid params" do
        it "assigns the purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
          assigns(:purchase_request).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "with valid params" do
        it "updates the requested purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
        end

        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
          assigns(:purchase_request).should eq(@purchase_request)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @purchase_request.id, :purchase_request => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested purchase_request as @purchase_request" do
          put :update, :id => @purchase_request.id, :purchase_request => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @purchase_request = purchase_requests(:purchase_request_00001)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested purchase_request" do
        delete :destroy, :id => @purchase_request.id
      end

      it "redirects to the purchase_requests list" do
        delete :destroy, :id => @purchase_request.id
        response.should redirect_to purchase_requests_url
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested purchase_request" do
        delete :destroy, :id => @purchase_request.id
      end

      it "redirects to the purchase_requests list" do
        delete :destroy, :id => @purchase_request.id
        response.should redirect_to purchase_requests_url
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested purchase_request" do
        delete :destroy, :id => @purchase_request.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @purchase_request.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested purchase_request" do
        delete :destroy, :id => @purchase_request.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @purchase_request.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
