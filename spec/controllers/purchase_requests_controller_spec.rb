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
        expect(assigns(:purchase_requests)).not_to be_empty
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all purchase_requests as @purchase_requests' do
        get :index
        expect(assigns(:purchase_requests).total_entries).to eq PurchaseRequest.count
        expect(assigns(:purchase_requests)).not_to be_empty
      end

      it "should get other user's index with user_id" do
        get :index, params: { user_id: users(:user1).username }
        expect(response).to be_successful
        expect(assigns(:purchase_requests).total_entries).to eq users(:user1).purchase_requests.count
        expect(assigns(:purchase_requests)).not_to be_empty
      end

      it "should get other user's index with order_list_id" do
        get :index, params: { order_list_id: 1 }
        expect(response).to be_successful
        expect(assigns(:purchase_requests).total_entries).to eq order_lists(:order_list_00001).purchase_requests.count
        expect(assigns(:purchase_requests)).not_to be_empty
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns my purchase_requests as @purchase_requests' do
        get :index
        expect(assigns(:purchase_requests)).not_to be_empty
      end

      it 'should be get my index without user_id' do
        get :index
        expect(assigns(:purchase_requests)).to eq users(:user1).purchase_requests
        expect(assigns(:purchase_requests).total_entries).to eq users(:user1).purchase_requests.count
        expect(response).to be_successful
      end

      it 'should get my index' do
        get :index, params: { user_id: users(:user1).username }
        expect(response).to redirect_to purchase_requests_url
        expect(assigns(:purchase_requests)).to be_nil
      end

      it 'should not get index with order_list_id' do
        get :index, params: { order_list_id: 1 }
        expect(response).to be_forbidden
        expect(assigns(:purchase_requests)).to be_nil
      end

      it 'should get my index in txt format' do
        get :index, params: { user_id: users(:user1).username, format: :txt }
        expect(response).to redirect_to purchase_requests_url(format: :txt)
        expect(assigns(:purchase_requests)).to be_nil
      end

      it 'should get my index in rss format' do
        get :index, params: { user_id: users(:user1).username, format: 'rss' }
        expect(response).to redirect_to purchase_requests_url(format: :rss)
        expect(assigns(:purchase_requests)).to be_nil
      end

      it "should not get other user's index" do
        get :index, params: { user_id: users(:librarian1).username }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @purchase_requests' do
        get :index
        expect(assigns(:purchase_requests)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
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
        expect(assigns(:purchase_request)).to eq(@purchase_request)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        expect(assigns(:purchase_request)).to eq(@purchase_request)
      end

      it 'should show purchase_request without user_id' do
        get :show, params: { id: purchase_requests(:purchase_request_00002).id }
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        expect(assigns(:purchase_request)).to eq(@purchase_request)
      end

      it 'should show my purchase request' do
        get :show, params: { id: @purchase_request.id }
        expect(response).to be_successful
      end

      it "should not show other user's purchase request" do
        get :show, params: { id: purchase_requests(:purchase_request_00001).id }
        expect(response).to be_forbidden
      end

      render_views
      it 'should not show add or delete order link' do
        get :show, params: { id: @purchase_request.id }
        expect(response).to be_successful
        expect(response.body).not_to match /\/order\/new/
        expect(response.body).not_to match /delete.*\/order/
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested purchase_request as @purchase_request' do
        get :show, params: { id: @purchase_request.id }
        expect(assigns(:purchase_request)).to eq(@purchase_request)
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested purchase_request as @purchase_request' do
        get :new
        expect(assigns(:purchase_request)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        expect(assigns(:purchase_request)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        expect(assigns(:purchase_request)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested purchase_request as @purchase_request' do
        get :new
        expect(assigns(:purchase_request)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        expect(assigns(:purchase_request)).to eq(purchase_requests(:purchase_request_00001))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        expect(assigns(:purchase_request)).to eq(purchase_requests(:purchase_request_00001))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should edit my purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00003).id }
        expect(response).to be_successful
      end

      it "should not edit other user's purchase_request" do
        get :edit, params: { id: purchase_requests(:purchase_request_00002).id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested purchase_request as @purchase_request' do
        get :edit, params: { id: purchase_requests(:purchase_request_00001).id }
        expect(response).to redirect_to new_user_session_url
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
          expect(assigns(:purchase_request)).to be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(response).to redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(assigns(:purchase_request)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(assigns(:purchase_request)).to be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(response).to redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(assigns(:purchase_request)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end

      it "should create purchase_request with other user's user_id" do
        post :create, params: { purchase_request: { title: 'test', user_id: users(:user1).id } }
        expect(response).to redirect_to purchase_request_url(assigns(:purchase_request))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(assigns(:purchase_request)).to be_valid
        end

        it 'redirects to the created purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(response).to redirect_to(purchase_request_url(assigns(:purchase_request)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(assigns(:purchase_request)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end

      it 'should create purchase_request without user_id' do
        post :create, params: { purchase_request: { title: 'test', user_id: users(:user1).id, pub_date: 2010 } }
        expect(assigns(:purchase_request).date_of_publication).to eq Time.zone.parse('2010-01-01')
        expect(response).to redirect_to purchase_request_url(assigns(:purchase_request))
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @attrs }
          expect(assigns(:purchase_request)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { purchase_request: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved purchase_request as @purchase_request' do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(assigns(:purchase_request)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { purchase_request: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
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
          expect(assigns(:purchase_request)).to eq(@purchase_request)
          expect(response).to redirect_to purchase_request_url(assigns(:purchase_request))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          expect(response).to render_template('edit')
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
          expect(assigns(:purchase_request)).to eq(@purchase_request)
          expect(response).to redirect_to purchase_request_url(assigns(:purchase_request))
        end
      end

      describe 'with invalid params' do
        it 'assigns the purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          expect(assigns(:purchase_request)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          expect(response).to render_template('edit')
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
          expect(assigns(:purchase_request)).to eq(@purchase_request)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end

      it 'should update my purchase_request' do
        put :update, params: { id: purchase_requests(:purchase_request_00003).id, purchase_request: { note: 'test' } }
        expect(response).to redirect_to purchase_request_url(assigns(:purchase_request))
      end

      it "should not update other user's purchase_request" do
        put :update, params: { id: purchase_requests(:purchase_request_00002).id, purchase_request: { note: 'test' } }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @purchase_request.id, purchase_request: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested purchase_request as @purchase_request' do
          put :update, params: { id: @purchase_request.id, purchase_request: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
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
        expect(response).to redirect_to purchase_requests_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'redirects to the purchase_requests list' do
        delete :destroy, params: { id: @purchase_request.id }
        expect(response).to redirect_to purchase_requests_url
      end

      it "should destroy other user's purchase request" do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00003).id }
        expect(response).to redirect_to purchase_requests_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @purchase_request.id }
        expect(response).to be_forbidden
      end

      it 'should destroy my purchase_request' do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00003).id }
        expect(response).to redirect_to purchase_requests_url
      end

      it "should not destroy other user's purchase_request" do
        delete :destroy, params: { id: purchase_requests(:purchase_request_00002).id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested purchase_request' do
        delete :destroy, params: { id: @purchase_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @purchase_request.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
