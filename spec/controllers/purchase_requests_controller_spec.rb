require 'spec_helper'

describe PurchaseRequestsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
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
        sign_in Factory(:admin)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = Factory.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = Factory.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = Factory.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end

    describe "When not logged in" do
      it "assigns the requested purchase_request as @purchase_request" do
        purchase_request = Factory.create(:purchase_request)
        get :show, :id => purchase_request.id
        assigns(:purchase_request).should eq(purchase_request)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested purchase_request as @purchase_request" do
        get :new
        assigns(:purchase_request).should_not be_valid
        response.should be_forbidden
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
end
