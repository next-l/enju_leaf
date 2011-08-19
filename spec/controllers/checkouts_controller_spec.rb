require 'spec_helper'

describe CheckoutsController do
  fixtures :all

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:admin)
      5.times do
        FactoryGirl.create(:user)
      end
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq(Checkout.not_returned.order('created_at DESC').page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "assigns all checkouts as @checkouts" do
        get :index, :user_id => @user.username
        assigns(:checkouts).should eq(@user.checkouts.not_returned.order('created_at DESC').page(1))
      end

      it "should be redirected if an username is not specified" do
        get :index
        assigns(:checkouts).should eq(Checkout.order('created_at DESC').all)
        response.should redirect_to(user_checkouts_url(@user))
      end

      it "should be forbidden if other's username is specified" do
        user = FactoryGirl.create(:user)
        get :index, :user_id => user.username
        assigns(:checkouts).should eq(Checkout.order('created_at DESC').all)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @checkouts" do
        get :index
        assigns(:checkouts).should_not be_empty
        response.should redirect_to(new_user_session_url)
      end

      it "assigns his own checkouts as @checkouts" do
        token = "AVRjefcBcey6f1WyYXDl"
        user = User.where(:checkout_icalendar_token => token).first
        get :index, :icalendar_token => token
        assigns(:checkouts).should eq user.checkouts.not_returned.order('created_at DESC').page(1)
        response.should be_success
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
      @attrs = {:due_date => 1.day.from_now}
      @invalid_attrs = {:item_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(user_checkout_url(@checkout.user, @checkout))
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(user_checkout_url(@checkout.user, @checkout))
        end
      end

      describe "with invalid params" do
        it "assigns the checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          assigns(:checkout).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "should be forbidden" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(user_checkouts_url(@checkout.user))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(user_checkouts_url(@checkout.user))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
      end

      it "should be forbidden" do
        delete :destroy, :id => @checkout.id, :user_id => @checkout.user.username
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
