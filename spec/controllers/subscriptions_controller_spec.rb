require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe SubscriptionsController do
  disconnect_sunspot

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all subscriptions as @subscriptions" do
        get :index
        assigns(:subscriptions).should eq(Subscription.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all subscriptions as @subscriptions" do
        get :index
        assigns(:subscriptions).should eq(Subscription.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all subscriptions as @subscriptions" do
        get :index
        assigns(:subscriptions).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all subscriptions as @subscriptions" do
        get :index
        assigns(:subscriptions).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :show, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :show, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :show, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end

    describe "When not logged in" do
      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :show, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subscription as @subscription" do
        get :new
        assigns(:subscription).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subscription as @subscription" do
        get :new
        assigns(:subscription).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested subscription as @subscription" do
        get :new
        assigns(:subscription).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subscription as @subscription" do
        get :new
        assigns(:subscription).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :edit, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :edit, :id => subscription.id
        assigns(:subscription).should eq(subscription)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :edit, :id => subscription.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested subscription as @subscription" do
        subscription = FactoryGirl.create(:subscription)
        get :edit, :id => subscription.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:subscription)
      @invalid_attrs = {:user_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created subscription as @subscription" do
          post :create, :subscription => @attrs
          assigns(:subscription).should be_valid
        end

        it "redirects to the created subscription" do
          post :create, :subscription => @attrs
          response.should redirect_to(subscription_url(assigns(:subscription)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subscription as @subscription" do
          post :create, :subscription => @invalid_attrs
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :subscription => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created subscription as @subscription" do
          post :create, :subscription => @attrs
          assigns(:subscription).should be_valid
        end

        it "redirects to the created subscription" do
          post :create, :subscription => @attrs
          response.should redirect_to(subscription_url(assigns(:subscription)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subscription as @subscription" do
          post :create, :subscription => @invalid_attrs
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :subscription => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created subscription as @subscription" do
          post :create, :subscription => @attrs
          assigns(:subscription).should be_valid
        end

        it "should be forbidden" do
          post :create, :subscription => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subscription as @subscription" do
          post :create, :subscription => @invalid_attrs
          assigns(:subscription).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subscription => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created subscription as @subscription" do
          post :create, :subscription => @attrs
          assigns(:subscription).should be_valid
        end

        it "should be forbidden" do
          post :create, :subscription => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved subscription as @subscription" do
          post :create, :subscription => @invalid_attrs
          assigns(:subscription).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :subscription => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @subscription = FactoryGirl.create(:subscription)
      @attrs = FactoryGirl.attributes_for(:subscription)
      @invalid_attrs = {:user_id => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
        end

        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
          assigns(:subscription).should eq(@subscription)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
        end

        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
          assigns(:subscription).should eq(@subscription)
          response.should redirect_to(@subscription)
        end
      end

      describe "with invalid params" do
        it "assigns the subscription as @subscription" do
          put :update, :id => @subscription, :subscription => @invalid_attrs
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @subscription, :subscription => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
        end

        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
          assigns(:subscription).should eq(@subscription)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested subscription" do
          put :update, :id => @subscription.id, :subscription => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @subscription.id, :subscription => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested subscription as @subscription" do
          put :update, :id => @subscription.id, :subscription => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @subscription = FactoryGirl.create(:subscription)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested subscription" do
        delete :destroy, :id => @subscription.id
      end

      it "redirects to the subscriptions list" do
        delete :destroy, :id => @subscription.id
        response.should redirect_to(subscriptions_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested subscription" do
        delete :destroy, :id => @subscription.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subscription.id
        response.should redirect_to(subscriptions_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested subscription" do
        delete :destroy, :id => @subscription.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subscription.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested subscription" do
        delete :destroy, :id => @subscription.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @subscription.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
