require 'spec_helper'

describe SearchHistoriesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin)
        sign_in @user
      end

      it "assigns all search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "assigns its own search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should eq @user.search_histories.order('created_at DESC').page(1)
        assert_response :success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "assigns its own search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should eq @user.search_histories.order('created_at DESC').page(1)
        assert_response :success
      end
    end

    describe "When not logged in" do
      it "assigns all search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should be_empty
        response.should redirect_to new_user_session_url
      end
    
      it "should not get other's search_histories" do
        get :index, :user_id => users(:admin).username
        assigns(:search_histories).should be_empty
        response.should redirect_to new_user_session_url
      end
    end
  end
end
