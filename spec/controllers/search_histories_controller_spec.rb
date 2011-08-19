require 'spec_helper'

describe SearchHistoriesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should be_empty
      end
    end
  end
end
