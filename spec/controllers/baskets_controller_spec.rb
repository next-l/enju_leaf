require 'spec_helper'

describe BasketsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all baskets as @baskets" do
        get :index, :user_id => users(:user1).username
        assigns(:baskets).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all baskets as @baskets" do
        get :index, :user_id => users(:user1).username
        assigns(:baskets).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested basket as @basket" do
        get :show, :id => 1, :user_id => users(:admin).username
        assigns(:basket).should eq(Basket.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested basket as @basket" do
        get :show, :id => 1, :user_id => users(:admin).username
        assigns(:basket).should eq(Basket.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:user_number => users(:user1).user_number }
      @invalid_attrs = {:user_number => 'invalid'}
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created basket as @basket" do
          post :create, :basket => {:user_number => users(:user1).user_number }
          assigns(:basket).should be_valid
        end
      end

      describe "with blank params" do
        it "assigns a newly created basket as @basket" do
          post :create, :basket => { }
          assigns(:basket).should_not be_valid
        end
      end

      describe "with invalid params" do
        it "assigns a newly created basket as @basket" do
          post :create, :basket => @invalid_attrs
          assigns(:basket).should_not be_valid
        end
      end
    end
  end
end
