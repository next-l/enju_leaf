require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe SubscriptionsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:subscription)
  end

  describe 'GET index', solr: true do
    before do
      Subscription.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all subscriptions as @subscriptions' do
        get :index
        assigns(:subscriptions).should eq(Subscription.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all subscriptions as @subscriptions' do
        get :index
        assigns(:subscriptions).should eq(Subscription.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all subscriptions as @subscriptions' do
        get :index
        assigns(:subscriptions).should be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all subscriptions as @subscriptions' do
        get :index
        assigns(:subscriptions).should be_nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :show, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :show, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :show, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :show, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscription as @subscription' do
        get :new
        assigns(:subscription).should_not be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscription as @subscription' do
        get :new
        assigns(:subscription).should_not be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested subscription as @subscription' do
        get :new
        assigns(:subscription).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subscription as @subscription' do
        get :new
        assigns(:subscription).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :edit, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :edit, params: { id: subscription.id }
        assigns(:subscription).should eq(subscription)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :edit, params: { id: subscription.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subscription as @subscription' do
        subscription = FactoryBot.create(:subscription)
        get :edit, params: { id: subscription.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { title: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created subscription as @subscription' do
          post :create, params: { subscription: @attrs }
          assigns(:subscription).should be_valid
        end

        it 'redirects to the created subscription' do
          post :create, params: { subscription: @attrs }
          response.should redirect_to(subscription_url(assigns(:subscription)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscription as @subscription' do
          post :create, params: { subscription: @invalid_attrs }
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { subscription: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created subscription as @subscription' do
          post :create, params: { subscription: @attrs }
          assigns(:subscription).should be_valid
        end

        it 'redirects to the created subscription' do
          post :create, params: { subscription: @attrs }
          response.should redirect_to(subscription_url(assigns(:subscription)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscription as @subscription' do
          post :create, params: { subscription: @invalid_attrs }
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { subscription: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created subscription as @subscription' do
          post :create, params: { subscription: @attrs }
          assigns(:subscription).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscription: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscription as @subscription' do
          post :create, params: { subscription: @invalid_attrs }
          assigns(:subscription).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscription: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created subscription as @subscription' do
          post :create, params: { subscription: @attrs }
          assigns(:subscription).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscription: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscription as @subscription' do
          post :create, params: { subscription: @invalid_attrs }
          assigns(:subscription).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscription: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @subscription = FactoryBot.create(:subscription)
      @attrs = valid_attributes
      @invalid_attrs = { title: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
        end

        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
          assigns(:subscription).should eq(@subscription)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
        end

        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
          assigns(:subscription).should eq(@subscription)
          response.should redirect_to(@subscription)
        end
      end

      describe 'with invalid params' do
        it 'assigns the subscription as @subscription' do
          put :update, params: { id: @subscription, subscription: @invalid_attrs }
          assigns(:subscription).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @subscription, subscription: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
        end

        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
          assigns(:subscription).should eq(@subscription)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested subscription' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @subscription.id, subscription: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscription as @subscription' do
          put :update, params: { id: @subscription.id, subscription: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @subscription = FactoryBot.create(:subscription)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested subscription' do
        delete :destroy, params: { id: @subscription.id }
      end

      it 'redirects to the subscriptions list' do
        delete :destroy, params: { id: @subscription.id }
        response.should redirect_to(subscriptions_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested subscription' do
        delete :destroy, params: { id: @subscription.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subscription.id }
        response.should redirect_to(subscriptions_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested subscription' do
        delete :destroy, params: { id: @subscription.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subscription.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested subscription' do
        delete :destroy, params: { id: @subscription.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subscription.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
