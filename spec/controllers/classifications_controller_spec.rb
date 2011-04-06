require 'spec_helper'

describe ClassificationsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all classifications as @classifications" do
        get :index
        assigns(:classifications).should_not be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested classification as @classification" do
        get :show, :id => 1
        assigns(:classification).should eq(Classification.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested classification as @classification" do
        get :show, :id => 1
        assigns(:classification).should eq(Classification.find(1))
      end
    end
  end
end
