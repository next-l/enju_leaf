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

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should assign the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
      end
    end

    describe "When not logged in" do
      it "should not assign the requested classification as @classification" do
        get :new
        assigns(:classification).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
