require 'spec_helper'

describe CheckoutsController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      Factory.create(:admin)
      5.times do
        Factory.create(:user)
      end
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq(Checkout.not_returned.paginate(:page => 1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = Factory(:user)
        sign_in @user
      end

      it "assigns all checkouts as @checkouts" do
        get :index, :user_id => @user.username
        assigns(:checkouts).should eq(@user.checkouts.not_returned.paginate(:page => 1))
      end

      it "should be redirected if an username is not specified" do
        get :index
        assigns(:checkouts).should eq(Checkout.not_returned.paginate(:page => 1))
        response.should redirect_to(user_checkouts_url(@user))
      end

      it "should be forbidden if other's username is specified" do
        get :index, :user_id => Factory(:user).username
        assigns(:checkouts).should eq(Checkout.not_returned.paginate(:page => 1))
        response.should be_forbidden
      end
    end
  end

  describe "POST create" do
    before(:each) do
      sign_in Factory(:admin)
      Factory(:library)
      @attrs = Factory.attributes_for(:item)
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "with valid params" do
      it "assigns a newly created checkout as @checkout" do
        post :create, :checkout => @attrs
        assigns(:checkout).should be_nil
      end

      it "redirects to the created checkout" do
        post :create, :checkout => @attrs
        response.should be_forbidden
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved checkout as @checkout" do
        post :create, :checkout => @invalid_attrs
        assigns(:checkout).should be_nil
      end

      it "should be forbidden" do
        post :create, :checkout => @invalid_attrs
        response.should be_forbidden
      end
    end

  end
end
