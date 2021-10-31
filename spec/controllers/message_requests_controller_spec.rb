require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe MessageRequestsController do
  fixtures :all
  disconnect_sunspot

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all message_requests as @message_requests' do
        get :index
        assigns(:message_requests).should eq(MessageRequest.not_sent.order('created_at DESC').page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all message_requests as @message_requests' do
        get :index
        assigns(:message_requests).should eq(MessageRequest.not_sent.order('created_at DESC').page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all message_requests as @message_requests' do
        get :index
        assigns(:message_requests).should be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all message_requests as @message_requests' do
        get :index
        assigns(:message_requests).should be_nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :show, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :show, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :show, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :show, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :edit, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :edit, params: { id: message_request.id }
        assigns(:message_request).should eq(message_request)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :edit, params: { id: message_request.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested message_request as @message_request' do
        message_request = FactoryBot.create(:message_request)
        get :edit, params: { id: message_request.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @message_request = FactoryBot.create(:message_request)
      @attrs = FactoryBot.attributes_for(:message_request).merge(body: 'test')
      @invalid_attrs = { body: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
        end

        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
          assigns(:message_request).should eq(@message_request)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
        end

        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
          assigns(:message_request).should eq(@message_request)
          response.should redirect_to(@message_request)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
        end

        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
          assigns(:message_request).should eq(@message_request)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested message_request' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @message_request.id, message_request: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message_request as @message_request' do
          put :update, params: { id: @message_request.id, message_request: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @message_request = FactoryBot.create(:message_request)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested message_request' do
        delete :destroy, params: { id: @message_request.id }
      end

      it 'redirects to the harvesting_requests list' do
        delete :destroy, params: { id: @message_request.id }
        response.should redirect_to(message_requests_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested message_request' do
        delete :destroy, params: { id: @message_request.id }
      end

      it 'redirects to the harvesting_requests list' do
        delete :destroy, params: { id: @message_request.id }
        response.should redirect_to(message_requests_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested message_request' do
        delete :destroy, params: { id: @message_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @message_request.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested message_request' do
        delete :destroy, params: { id: @message_request.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @message_request.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
