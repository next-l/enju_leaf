require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ReservesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should eq(Reserve.paginate(:page => 1, :order => ['reserves.expired_at DESC']))
      end
    end

    describe "When not logged in" do
      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = {:user_number => users(:user1).user_number, :manifestation_id => 5}
      @invalid_attrs = {:user_number => users(:user1).user_number, :manifestation_id => 'invalid'}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created reserve as @reserve" do
          post :create, :reserve => @attrs, :user_id => users(:user1).username
          assigns(:reserve).should be_valid
        end

        it "redirects to the created reserve" do
          post :create, :reserve => @attrs, :user_id => users(:user1).username
          response.should redirect_to(user_reserve_url(assigns(:reserve).user, assigns(:reserve)))
          assigns(:reserve).expired_at.should be_true
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved reserve as @reserve" do
          post :create, :reserve => @invalid_attrs, :user_id => users(:user1).username
          assigns(:reserve).should_not be_valid
        end

        it "redirects to the list" do
          post :create, :reserve => @invalid_attrs, :user_id => users(:user1).username
          assigns(:reserve).expired_at.should be_nil
          response.should be_success
        end
      end
    end
  end
end
