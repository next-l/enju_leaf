require 'spec_helper'

describe CheckoutsController do
  fixtures :all

  describe "GET index", :solr => true do
    before(:each) do
      FactoryGirl.create(:admin)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq Checkout.not_returned.order('checkouts.id DESC').page(1)
      end

      it "should get other user's index" do
        get :index, :user_id => users(:admin).username
        response.should be_success
        assigns(:checkouts).should eq users(:admin).checkouts.not_returned.order('checkouts.id DESC').page(1)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should get index" do
        get :index
        response.should be_success
      end

      it "should get index csv" do
        get :index, :format => 'csv'
        response.should be_success
      end

      it "should get index rss" do
        get :index, :format => 'rss'
        response.should be_success
      end

      it "should get overdue index" do
        get :index, :view => 'overdue'
        assigns(:checkouts).should eq Checkout.overdue(1.day.ago.beginning_of_day).order('checkouts.id DESC').page(1)
        response.should be_success
      end

      it "should get overdue index with nunber of days_overdue" do
        get :index, :view => 'overdue', :days_overdue => 2
        response.should be_success
        assigns(:checkouts).size.should > 0
      end

      it "should get overdue index with invalid number of days_overdue" do
        get :index, :view => 'overdue', :days_overdue => 'invalid days'
        response.should be_success
        assigns(:checkouts).size.should > 0
      end

      it "should get other user's index" do
        get :index, :user_id => users(:admin).username
        response.should be_success
        assigns(:checkouts).should eq users(:admin).checkouts.not_returned.order('checkouts.id DESC').page(1)
      end

      it "should get index with item_id" do
        get :index, :item_id => 1
        response.should be_success
        assigns(:checkouts).should eq items(:item_00001).checkouts.order('checkouts.id DESC').page(1)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all checkouts as @checkouts" do
        get :index
        assigns(:checkouts).should eq(users(:user1).checkouts.not_returned.order('checkouts.id DESC').page(1))
        response.should be_success
      end

      it "should be forbidden if other's username is specified" do
        user = FactoryGirl.create(:user)
        get :index, :user_id => user.username
        assigns(:checkouts).should be_nil
        response.should be_forbidden
      end

      it "should get my index feed" do
        get :index, :format => 'rss'
        response.should be_success
        assigns(:checkouts).should eq(users(:user1).checkouts.not_returned.order('checkouts.id DESC').page(1))
      end

      it "should get my index with user_id" do
        get :index, :user_id => users(:user1).username
        assigns(:checkouts).should be_nil
        response.should redirect_to checkouts_url
      end

      it "should get my index in csv format" do
        get :index, :user_id => users(:user1).username, :format => 'csv'
        response.should redirect_to checkouts_url(:format => :csv)
        assigns(:checkouts).should be_nil
      end

      it "should get my index in rss format" do
        get :index, :user_id => users(:user1).username, :format => 'rss'
        response.should redirect_to checkouts_url(:format => :rss)
        assigns(:checkouts).should be_nil
      end

      it "should not get other user's index" do
        get :index, :user_id => users(:admin).username
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @checkouts" do
        get :index
        assigns(:checkouts).should be_nil
        response.should redirect_to(new_user_session_url)
      end

      it "assigns his own checkouts as @checkouts" do
        token = "AVRjefcBcey6f1WyYXDl"
        user = User.where(:checkout_icalendar_token => token).first
        get :index, :icalendar_token => token
        assigns(:checkouts).should eq user.checkouts.not_returned.order('checkouts.id DESC')
        response.should be_success
      end

      it "should get ics template" do
        token = "AVRjefcBcey6f1WyYXDl"
        user = User.where(:checkout_icalendar_token => token).first
        get :index, :icalendar_token => token, :format => :ics
        assigns(:checkouts).should eq user.checkouts.not_returned.order('checkouts.id DESC')
        response.should be_success
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should show other user's content" do
        get :show, :id => 3
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should show other user's content" do
        get :show, :id => 3
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should show my account" do
        get :show, :id => 3
        response.should be_success
        assigns(:checkout).should eq checkouts(:checkout_00003)
      end

      it "should not show other user's checkout" do
        get :show, :id => 1
        response.should be_forbidden
        assigns(:checkout).should eq checkouts(:checkout_00001)
      end

      it "should not show missing checkout" do
        get :show, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When not logged in" do
      it "should not assign the requested checkout as @checkout" do
        get :show, :id => 1
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should edit other user's checkout" do
        get :edit, :id => 3
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should edit other user's checkout" do
        get :edit, :id => 3
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should edit my checkout" do
        sign_in users(:user1)
        get :edit, :id => 3
        response.should be_success
      end
  
      it "should not edit other user's checkout" do
        get :edit, :id => 1
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not edit checkout" do
        get :edit, :id => 1
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @checkout = checkouts(:checkout_00003)
      @attrs = {:due_date => 1.day.from_now}
      @invalid_attrs = {:item_identifier => 'invalid'}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs
        end

        it "assigns the requested checkout as @checkout" do
          old_due_date = @checkout.due_date
          put :update, :id => @checkout.id, :checkout => @attrs
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
          assigns(:checkout).due_date.should eq 1.day.from_now.end_of_day
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs
        end

        it "should ignore item_id" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs
          response.should redirect_to(assigns(:checkout))
          assigns(:checkout).changed?.should be_false
        end
      end

      it "should not update missing checkout" do
        put :update, :id => 'missing', :checkout => { }
        response.should be_missing
      end

      it "should remove its own checkout history" do
        put :remove_all, :user_id => users(:user1).username
        users(:user1).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it "should not remove other checkout history" do
        put :remove_all, :user_id => users(:user2).username
        users(:user1).checkouts.returned.count.should_not eq 0
        response.should redirect_to checkouts_url
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @attrs, :user_id => @checkout.user.username
          assigns(:checkout).should eq(@checkout)
          response.should redirect_to(assigns(:checkout))
        end
      end

      describe "with invalid params" do
        it "assigns the checkout as @checkout" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          assigns(:checkout).should be_valid
        end

        it "should ignore item_id" do
          put :update, :id => @checkout.id, :checkout => @invalid_attrs, :user_id => @checkout.user.username
          response.should redirect_to(assigns(:checkout))
        end
      end
  
      it "should update checkout item that is reserved" do
        put :update, :id => 8, :checkout => { }
        flash[:notice].should eq I18n.t('checkout.this_item_is_reserved')
        response.should redirect_to edit_checkout_url(assigns(:checkout))
      end
  
      it "should update other user's checkout" do
        put :update, :id => 1, :checkout => { }
        response.should redirect_to checkout_url(assigns(:checkout))
      end

      it "should remove its own checkout history" do
        put :remove_all, :user_id => users(:user1).username
        users(:user1).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it "should not remove other checkout history" do
        put :remove_all, :user_id => users(:user2).username
        users(:user1).checkouts.returned.count.should_not eq 0
        response.should redirect_to checkouts_url
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
        end

        it "assigns the requested checkout as @checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
          assigns(:checkout).should eq(checkouts(:checkout_00001))
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested checkout as @checkout" do
          put :update, :id => checkouts(:checkout_00001).id, :checkout => @attrs
          response.should be_forbidden
        end
      end

      it "should not update other user's checkout" do
        put :update, :id => 1, :checkout => { }
        response.should be_forbidden
      end
  
      it "should not update checkout already renewed" do
        put :update, :id => 9, :checkout => { }
        flash[:notice].should eq I18n.t('checkout.excessed_renewal_limit')
        response.should redirect_to edit_checkout_url(assigns(:checkout))
      end

      it "should update my checkout" do
        put :update, :id => 3, :checkout => { }
        assigns(:checkout).should be_valid
        response.should redirect_to checkout_url(assigns(:checkout))
      end
  
      it "should not update checkout without item_id" do
        put :update, :id => 3, :checkout => {:item_id => nil}
        assigns(:checkout).should be_valid
        response.should redirect_to(assigns(:checkout))
        assigns(:checkout).changed?.should be_false
      end

      it "should remove its own checkout history" do
        put :remove_all, :user_id => users(:user1).username
        assigns(:user).checkouts.returned.count.should eq 0
        response.should redirect_to checkouts_url
      end

      it "should not remove other checkout history" do
        put :remove_all, :user_id => users(:admin).username
        assigns(:user).checkouts.returned.count.should eq 0
        response.should be_forbidden
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
      @returned_checkout = checkouts(:checkout_00012)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id
      end

      it "should not destroy the checkout that is not checked in" do
        delete :destroy, :id => @checkout.id
        response.should be_forbidden
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @returned_checkout.id
        response.should redirect_to(user_checkouts_url(@returned_checkout.user))
      end

      it "should not destroy missing checkout" do
        delete :destroy, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested checkout" do
        delete :destroy, :id => @checkout.id
      end

      it "should not destroy the checkout that is not checked in" do
        delete :destroy, :id => @checkout.id
        response.should be_forbidden
      end

      it "redirects to the checkouts list" do
        delete :destroy, :id => @returned_checkout.id
        response.should redirect_to(user_checkouts_url(@returned_checkout.user))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested checkout" do
        delete :destroy, :id => checkouts(:checkout_00001).id
      end

      it "should be forbidden" do
        delete :destroy, :id => checkouts(:checkout_00001).id
        response.should be_forbidden
      end

      it "should destroy my checkout" do
        delete :destroy, :id => 13
        response.should redirect_to user_checkouts_url(users(:user1))
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
