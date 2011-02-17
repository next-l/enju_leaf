require 'spec_helper'

describe CheckinsController do
  fixtures :all

  def mock_user(stubs={})
    (@mock_user ||= mock_model(Checkin).as_null_object).tap do |user|
      user.stub(stubs) unless stubs.empty?
    end
  end

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

      it "assigns all checkins as @checkins" do
        get :index
        assigns(:checkins).should eq(Checkin.all)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all checkins as @checkins" do
        get :index
        assigns(:checkins).should eq(Checkin.all)
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
      it "assigns a newly created checkin as @checkin" do
        post :create, :checkin => @attrs
        assigns(:checkin).should be_valid
      end

      it "redirects to the created checkin" do
        post :create, :checkin => @attrs
        response.should redirect_to(user_basket_checkins_url(assigns(:basket).user, assigns(:basket)))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved checkin as @checkin" do
        post :create, :checkin => @invalid_attrs
        assigns(:checkin).should be_valid
      end

      it "redirects to the list" do
        post :create, :checkin => @invalid_attrs
        response.should redirect_to(user_basket_checkins_url(assigns(:basket).user, assigns(:basket)))
      end
    end

  end
end
