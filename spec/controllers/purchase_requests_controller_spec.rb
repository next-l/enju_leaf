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
end
