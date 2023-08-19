require 'rails_helper'

describe PurchaseRequestsController do
  fixtures :all

  describe 'GET index', solr: true do
    before do
      PurchaseRequest.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all purchase_requests as @purchase_requests' do
        get :index
        assigns(:purchase_requests).should_not be_empty
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all purchase_requests as @purchase_requests' do
        get :index
        assigns(:purchase_requests).total_entries.should eq PurchaseRequest.count
        assigns(:purchase_requests).should_not be_empty
      end

      it "should get other user's index with user_id" do
        get :index, params: { user_id: users(:user1).username }
        response.should be_successful
        assigns(:purchase_requests).total_entries.should eq users(:user1).purchase_requests.count
        assigns(:purchase_requests).should_not be_empty
      end

      it "should get other user's index with order_list_id" do
        get :index, params: { order_list_id: 1 }
        response.should be_successful
        assigns(:purchase_requests).total_entries.should eq order_lists(:order_list_00001).purchase_requests.count
        assigns(:purchase_requests).should_not be_empty
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns my purchase_requests as @purchase_requests' do
        get :index
        assigns(:purchase_requests).should_not be_empty
      end

      it 'should be get my index without user_id' do
        get :index
        assigns(:purchase_requests).should eq users(:user1).purchase_requests
        assigns(:purchase_requests).total_entries.should eq users(:user1).purchase_requests.count
        response.should be_successful
      end

      it 'should get my index' do
        get :index, params: { user_id: users(:user1).username }
        response.should redirect_to purchase_requests_url
        assigns(:purchase_requests).should be_nil
      end

      it 'should not get index with order_list_id' do
        get :index, params: { order_list_id: 1 }
        response.should be_forbidden
        assigns(:purchase_requests).should be_nil
      end

      it 'should get my index in csv format' do
        get :index, params: { user_id: users(:user1).username, format: 'csv' }
        response.should redirect_to purchase_requests_url(format: :csv)
        assigns(:purchase_requests).should be_nil
      end

      it 'should get my index in rss format' do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        response.should redirect_to purchase_requests_url(format: :rss)
        assigns(:purchase_requests).should be_nil
      end

      it "should not get other user's index" do
        get :index, params: { user_id: users(:librarian1).username }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @purchase_requests' do
        get :index
        assigns(:purchase_requests).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @purchase_request = purchase_requests(:purchase_request_00003)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        assigns(:purchase_request).should eq(@purchase_request)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        assigns(:purchase_request).should eq(@purchase_request)
      end

      it 'should show purchase_request without user_id' do
        get :show, params: { id: purchase_requests(:purchase_request_00002).id }
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        assigns(:purchase_request).should eq(@purchase_request)
      end

      it 'should show my purchase request' do
        get :show, params: { id: @purchase_request.id }
        response.should be_successful
      end

      it "should not show other user's purchase request" do
        get :show, params: { id: purchase_requests(:purchase_request_00001).id }
        response.should be_forbidden
      end

      render_views
      it 'should not show add or delete order link' do
        get :show, params: { id: @purchase_request.id }
        response.should be_successful
        response.body.should_not match /\/order\/new/
        response.body.should_not match /delete.*\/order/
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        assigns(:purchase_request).should eq(@purchase_request)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested purchase_request as @purchase_request' do
        get :new
        assigns(:purchase_request).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        assigns(:purchase_request).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        assigns(:purchase_request).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        assigns(:purchase_request).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        assigns(:purchase_request).should eq(purchase_requests(:purchase_request_00001))
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        assigns(:purchase_request).should eq(purchase_requests(:purchase_request_00001))
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should edit my purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00003).id }
        response.should be_successful
      end

      it "should not edit other user's purchase_request" do
        get :edit, params: { id: purchase_requests(:purchase_request_00002).id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:purchase_request)
      @invalid_attrs = { title: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          assigns(:purchase_request).should be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          response.should redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          assigns(:purchase_request).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          assigns(:purchase_request).should be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          response.should redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          assigns(:purchase_request).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          response.should render_template('new')
        end
      end

      it "should create purchase_request with other user's user_id" do
        post :create, params: { purchase_request: { title: 'test', user_id: users(:user1).id } }
        response.should redirect_to purchase_request_url(assigns(:purchase_request))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          assigns(:purchase_request).should be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          response.should redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          assigns(:purchase_request).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          response.should render_template('new')
        end
      end

      it 'should create purchase_request without user_id' do
        post :create, params: { purchase_request: { title: 'test', user_id: users(:user1).id, pub_date: 2010 } }
        assigns(:purchase_request).date_of_publication.should eq Time.zone.parse('2010-01-01')
        response.should redirect_to purchase_request_url(assigns(:purchase_request))
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          assigns(:purchase_request).should be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { purchase_request: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          assigns(:purchase_request).should be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { purchase_request: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @purchase_request = purchase_requests(:purchase_request_00001)
      @attrs = FactoryBot.attributes_for(:purchase_request)
      @invalid_attrs = { title: '' }
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        @user = FactoryBot.create(:admin)
        sign_in @user
      end

      describe 'with valid params' do
        it 'updates the requested purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
        end

        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
          assigns(:purchase_request).should eq(@purchase_request)
          response.should redirect_to purchase_request_url(assigns(:purchase_request))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        @user = FactoryBot.create(:librarian)
        sign_in @user
      end

      describe 'with valid params' do
        it 'updates the requested purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
        end

        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
          assigns(:purchase_request).should eq(@purchase_request)
          response.should redirect_to purchase_request_url(assigns(:purchase_request))
        end
      end

      describe 'with invalid params' do
        it 'assigns the purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          assigns(:purchase_request).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
        end

        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
          assigns(:purchase_request).should eq(@purchase_request)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          response.should be_forbidden
        end
      end

      it 'should update my purchase_request' do
        put :update, params: { id: purchase_requests(:purchase_request_00003).id, purchase_request: { note: 'test' } }
        response.should redirect_to purchase_request_url(assigns(:purchase_request))
      end

      it "should not update other user's purchase_request" do
        put :update, params: { id: purchase_requests(:purchase_request_00002).id, purchase_request: { note: 'test' } }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @purchase_request = purchase_requests(:purchase_request_00001)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'redirects to the purchase_requests list' do
        delete :destroy, params: { id: @purchase_request.id }
        response.should redirect_to purchase_requests_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'redirects to the purchase_requests list' do
        delete :destroy, params: { id: @purchase_request.id }
        response.should redirect_to purchase_requests_url
      end

      it "should destroy other user's purchase request" do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00003).id }
        response.should redirect_to purchase_requests_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @purchase_request.id }
        response.should be_forbidden
      end

      it 'should destroy my purchase_request' do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00003).id }
        response.should redirect_to purchase_requests_url
      end

      it "should not destroy other user's purchase_request" do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00002).id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @purchase_request.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
