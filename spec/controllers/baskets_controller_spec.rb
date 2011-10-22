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
        response.should be_success
      end

      it "should not get index without user_id" do
        get :index
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all baskets as @baskets" do
        get :index, :user_id => users(:user1).username
        assigns(:baskets).should_not be_empty
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all baskets as @baskets" do
        get :index, :user_id => users(:user1).username
        assigns(:baskets).should be_empty
        response.should be_forbidden
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

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
        @basket = baskets(:basket_00001)
      end

      it "assigns the requested basket as @basket" do
        get :edit, :id => @basket.id
        assigns(:basket).should eq(@basket)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
        @basket = baskets(:basket_00001)
      end

      it "assigns the requested basket as @basket" do
        get :edit, :id => @basket.id
        assigns(:basket).should eq(@basket)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
        @basket = baskets(:basket_00001)
      end

      it "should not assign the requested basket as @basket" do
        get :edit, :id => @basket.id
        assigns(:basket).should eq(@basket)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      before(:each) do
        @basket = baskets(:basket_00001)
      end

      it "should not assign the requested basket as @basket" do
        get :edit, :id => @basket.id
        assigns(:basket).should eq(@basket)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:user_number => users(:user1).user_number }
      @invalid_attrs = {:user_number => 'invalid'}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
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

      it "should not create basket when user is suspended" do
        post :create, :basket => {:user_number => users(:user4).user_number }
        assigns(:basket).should_not be_valid
        assigns(:basket).errors["base"].include?(I18n.t('basket.this_account_is_suspended')).should be_true
        response.should be_success
      end

      it "should not create basket when user is not found" do
        post :create, :basket => {:user_number => 'not found' }
        assigns(:basket).should_not be_valid
        assigns(:basket).errors["base"].include?(I18n.t('user.not_found')).should be_true
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created basket as @basket" do
          post :create, :basket => {:user_number => users(:user1).user_number }
          assigns(:basket).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :basket => {:user_number => users(:user1).user_number }
          response.should be_forbidden
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
