require 'spec_helper'

describe BasketsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
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
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested basket as @basket" do
        get :show, :id => 1, :user_id => users(:admin).username
        assigns(:basket).should eq(Basket.find(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested basket as @basket" do
        get :show, :id => 1, :user_id => users(:admin).username
        assigns(:basket).should eq(Basket.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested basket as @basket" do
        get :show, :id => 1, :user_id => users(:admin).username
        assigns(:basket).should eq(Basket.find(1))
        response.should be_forbidden
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

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested basket as @basket" do
        get :new
        assigns(:basket).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested basket as @basket" do
        get :new
        assigns(:basket).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested basket as @basket" do
        get :new
        assigns(:basket).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested basket as @basket" do
        get :new
        assigns(:basket).should_not be_valid
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
        sign_in FactoryGirl.create(:librarian)
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

    describe "When not logged in" do
      describe "with blank params" do
        it "assigns a newly created basket as @basket" do
          post :create, :basket => { }
          assigns(:basket).should_not be_valid
        end

        it "should be redirected to new_user_session_url" do
          post :create, :basket => { }
          assigns(:basket).should_not be_valid
          assert_response :redirect
          response.should redirect_to new_user_session_url
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @attrs = {:user_id => users(:user1).username}
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested basket" do
          put :update, :id => 8, :basket => @attrs
        end

        it "assigns the requested basket as @basket" do
          put :update, :id => 8, :basket => @attrs
          assigns(:basket).checkouts.first.item.circulation_status.name.should eq 'On Loan'
          response.should redirect_to(user_checkouts_url(assigns(:basket).user))
        end
      end
    end
  end
end
