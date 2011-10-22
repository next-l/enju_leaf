require 'spec_helper'

describe SearchHistoriesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        @user = users(:admin)
        sign_in @user
      end

      it "assigns all search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should_not be_empty
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = users(:librarian1)
        sign_in @user
      end

      it "assigns its own search_histories as @search_histories" do
        get :index
        assigns(:search_histories).should eq @user.search_histories.order('created_at DESC').page(1)
        assert_response :success
      end

      it "assigns failed search_histories as @search_histories" do
        get :index, :mode => 'not_found'
        assigns(:search_histories).should eq @user.search_histories.not_found.order('created_at DESC').page(1)
        assert_response :success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = users(:user1)
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

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in users(:admin)
        @search_history = search_histories(:one)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:one)
        end

        it "assigns the requested search_history as @search_history" do
          get :show, :id => @search_history.id
          response.should be_success
          assigns(:search_history).should eq(@search_history)
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "assigns the requested search_history as @search_history" do
          get :show, :id => @search_history.id
          response.should be_success
          assigns(:search_history).should eq(@search_history)
        end
      end

      it "should not show missing search_history" do
        get :show, :id => 100
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in users(:librarian1)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "assigns the requested search_history as @search_history" do
          get :show, :id => @search_history.id
          response.should be_success
          assigns(:search_history).should eq(@search_history)
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:one)
        end

        it "should be forbidden" do
          get :show, :id => @search_history.id
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in users(:user1)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:three)
        end

        it "assigns the requested search_history as @search_history" do
          get :show, :id => @search_history.id
          response.should be_success
          assigns(:search_history).should eq(@search_history)
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "should be forbidden" do
          get :show, :id => @search_history.id
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      before(:each) do
        @search_history = search_histories(:one)
      end

      it "should be forbidden" do
        get :show, :id => @search_history.id
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in users(:admin)
        @search_history = search_histories(:one)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:one)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "redirects to the search_histories list" do
          delete :destroy, :id => @search_history.id
          response.should redirect_to search_histories_url
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "redirects to the search_histories list" do
          delete :destroy, :id => @search_history.id
          response.should redirect_to search_histories_url
        end
      end

      it "should not destroy missing search_history" do
        delete :destroy, :id => 100
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in users(:librarian1)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "redirects to the search_histories list" do
          delete :destroy, :id => @search_history.id
          response.should redirect_to search_histories_url
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:one)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "should be forbidden" do
          delete :destroy, :id => @search_history.id
          response.should be_forbidden
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in users(:user1)
      end

      describe "if the record is mine" do
        before(:each) do
          @search_history = search_histories(:three)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "redirects to the search_histories list" do
          delete :destroy, :id => @search_history.id
          response.should redirect_to search_histories_url
        end
      end

      describe "if the record is not mine" do
        before(:each) do
          @search_history = search_histories(:two)
        end

        it "destroys the requested search_history" do
          delete :destroy, :id => @search_history.id
        end

        it "should be forbidden" do
          delete :destroy, :id => @search_history.id
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      before(:each) do
        @search_history = search_histories(:one)
      end

      it "destroys the requested search_history" do
        delete :destroy, :id => @search_history.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @search_history.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
