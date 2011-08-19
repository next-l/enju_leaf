require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe ReservesController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should eq(Reserve.order('reserves.expired_at DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all reserves as @reserves" do
        get :index
        assigns(:reserves).should eq(Reserve.order('reserves.expired_at DESC').page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "assigns empty as @reserves" do
        get :index
        assigns(:reserves).should be_nil
      end

      it "should be redirected to its own index" do
        get :index
        response.should redirect_to user_reserves_url(@user)
      end

      describe "When my user_id is specified" do
        it "assigns my reserves as @reserves" do
          get :index, :user_id => @user.username
          assigns(:reserves).should be_empty
          response.should be_success
        end

        it "assigns my reservation feed as @reserves" do
          get :index, :user_id => @user.username, :format => :rss
          assigns(:reserves).should be_empty
          response.should be_success
        end
      end

      describe "When other user_id is specified" do
        before(:each) do
          @user = FactoryGirl.create(:user)
        end

        it "should not get any reserve as @reserves" do
          get :index, :user_id => @user.username
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      it "assigns empty as @reserves" do
        get :index
        assigns(:reserves).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :show, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :show, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :show, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When not logged in" do
      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :show, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested reserve as @reserve" do
        get :new
        assigns(:reserve).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
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

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :edit, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :edit, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :edit, :id => reserve.id
        assigns(:reserve).should eq(reserve)
      end
    end

    describe "When not logged in" do
      it "should not assign the requested reserve as @reserve" do
        reserve = FactoryGirl.create(:reserve)
        get :edit, :id => reserve.id
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
        sign_in FactoryGirl.create(:admin)
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
          response.should render_template("new")
          response.should be_success
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
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
          response.should render_template("new")
          response.should be_success
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "with valid params" do
        it "assigns a newly created reserve as @reserve" do
          post :create, :reserve => @attrs, :user_id => @user.username
          assigns(:reserve).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :reserve => @attrs, :user_id => @user.username
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved reserve as @reserve" do
          post :create, :reserve => @invalid_attrs, :user_id => @user.username
          assigns(:reserve).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :reserve => @invalid_attrs, :user_id => @user.username
          assigns(:reserve).expired_at.should be_nil
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created reserve as @reserve" do
          post :create, :reserve => @attrs
          assigns(:reserve).should_not be_valid
        end

        it "redirects to the login page" do
          post :create, :reserve => @attrs
          response.should redirect_to new_user_session_url
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved reserve as @reserve" do
          post :create, :reserve => @invalid_attrs, :user_id => users(:user1).username
          assigns(:reserve).should_not be_valid
        end

        it "redirects to the login page" do
          post :create, :reserve => @invalid_attrs, :user_id => users(:user1).username
          assigns(:reserve).expired_at.should be_nil
          response.should redirect_to new_user_session_url
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @reserve = FactoryGirl.create(:reserve)
      @attrs = FactoryGirl.attributes_for(:reserve)
      @invalid_attrs = {:manifestation_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
        end

        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
          assigns(:reserve).should eq(@reserve)
          response.should redirect_to(user_reserve_url(assigns(:reserve).user, assigns(:reserve)))
        end
      end

      describe "with invalid params" do
        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
        end

        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
          assigns(:reserve).should eq(@reserve)
          response.should redirect_to(user_reserve_url(assigns(:reserve).user, assigns(:reserve)))
        end
      end

      describe "with invalid params" do
        it "assigns the reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
          assigns(:reserve).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
        end

        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
          assigns(:reserve).should eq(@reserve)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested reserve" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
        end

        it "should be forbidden" do
          put :update, :id => @reserve.id, :reserve => @attrs, :user_id => @reserve.user.username
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested reserve as @reserve" do
          put :update, :id => @reserve.id, :reserve => @invalid_attrs, :user_id => @reserve.user.username
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @reserve = FactoryGirl.create(:reserve)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested reserve" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
      end

      it "redirects to the reserves list" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
        response.should redirect_to(user_reserves_url(assigns(:reserve).user))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested reserve" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
      end

      it "redirects to the reserves list" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
        response.should redirect_to(user_reserves_url(assigns(:reserve).user))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested reserve" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
      end

      it "should be forbidden" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested reserve" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
      end

      it "should be forbidden" do
        delete :destroy, :id => @reserve.id, :user_id => @reserve.user.username
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
