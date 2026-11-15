require 'rails_helper'

describe MessagesController do
  fixtures :all

  describe 'GET index', solr: true do
    before do
      Message.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should get its own messages' do
        get :index
        expect(assigns(:messages)).not_to be_nil
        expect(response).to be_successful
      end

      describe 'When user_id is specified' do
        it 'assigns all messages as @messages' do
          get :index, params: { user_id: @user.username }
          expect(assigns(:messages)).not_to be_nil
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should get its own messages' do
        get :index
        expect(assigns(:messages)).not_to be_nil
        expect(response).to be_successful
      end

      describe 'When user_id is specified' do
        it 'assigns all messages as @messages' do
          get :index, params: { user_id: @user.username }
          expect(assigns(:messages)).not_to be_nil
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'When user_id is specified' do
        it 'assigns all messages as @messages' do
          get :index
          expect(assigns(:messages)).not_to be_nil
        end
      end

      it 'should get its own messages' do
        get :index
        expect(assigns(:messages)).not_to be_nil
        expect(response).to be_successful
      end

      it 'should get index with query' do
        get :index, params: { query: 'you' }
        expect(assigns(:messages).first.receiver).to eq users(:user1)
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'assigns all messages as @messages' do
        get :index
        expect(assigns(:messages)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested message as @message' do
        message = messages(:user1_to_user2_1)
        expect do
          get :show, params: { id: message.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:message)).to be_nil
        # response.should be_missing
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested message as @message' do
        message = messages(:user1_to_user2_1)
        expect do
          get :show, params: { id: message.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:message)).to be_nil
        # response.should be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_user

      it 'should show my message' do
        get :show, params: { id: messages(:user2_to_user1_1).id }
        expect(response).to be_successful
      end

      it "should should not show other user's message" do
        expect do
          get :show, params: { id: messages(:user1_to_user2_1).id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        # response.should be_missing
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested message as @message' do
        get :show, params: { id: messages(:user1_to_user2_1).id }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested message as @message' do
        get :new
        expect(assigns(:message)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested message as @message' do
        get :new
        expect(assigns(:message)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested message as @message' do
        get :new
        expect(assigns(:message)).to be_nil
        expect(response).to be_forbidden
      end

      it 'should not get new template without parent_id' do
        get :new
        expect(response).to be_forbidden
      end

      it 'should not get new template with invalid parent_id' do
        get :new, params: { parent_id: 1 }
        expect(response).to be_forbidden
      end

      it 'should not get new template with valid parent_id' do
        get :new, params: { parent_id: 2 }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested message as @message' do
        get :new
        expect(assigns(:message)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested message as @message' do
        message = messages(:user1_to_user2_1)
        expect do
          get :edit, params: { id: message.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:message)).to be_nil
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested message as @message' do
        message = messages(:user1_to_user2_1)
        expect do
          get :edit, params: { id: message.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:message)).to be_nil
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested message as @message' do
        message = messages(:user1_to_user2_1)
        expect do
          get :edit, params: { id: message.id }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(assigns(:message)).to be_nil
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested message as @message' do
        message = FactoryBot.create(:message)
        get :edit, params: { id: message.id }
        expect(assigns(:message)).to be_nil
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { recipient: users(:user1).username, subject: 'test', body: 'test' }
      @invalid_attrs = { recipient: users(:user1).username, subject: 'test', body: '' }
      @invalid_user_attrs = { recipient: 'invalid_user', subject: 'test', body: 'test' }
      @blank_user_attrs   = { recipient: '', subject: 'test', body: 'test' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created message as @message' do
          post :create, params: { message: @attrs, user_id: users(:user1).username }
          expect(assigns(:message)).to be_valid
        end

        it 'redirects to the created message' do
          post :create, params: { message: @attrs, user_id: users(:user1).username }
          expect(response).to redirect_to(messages_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved message as @message' do
          post :create, params: { message: @invalid_attrs, user_id: users(:user1).username }
          expect(assigns(:message)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { message: @invalid_attrs, user_id: users(:user1).username }
          expect(response).to render_template('new')
          expect(response).to be_successful
        end
      end

      describe 'with invalid recipient' do
        it "re-renders the 'new' template" do
          post :create, params: { message: @invalid_user_attrs }
          message = assigns(:message)
          expect(message).not_to be_valid
          expect(message.errors).to have_key :receiver
          expect(message.errors.added?(:receiver, :blank)).to be_truthy
          expect(response).to render_template('new')
        end

        it "re-renders the 'new' template" do
          post :create, params: { message: @blank_user_attrs }
          message = assigns(:message)
          expect(message).not_to be_valid
          expect(message.errors).to have_key :recipient
          expect(message.errors.added?(:recipient, :blank)).to be_truthy
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should create message without parent_id' do
        post :create, params: { message: { recipient: 'user2', subject: 'test', body: 'test' } }
        expect(response).to redirect_to messages_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not create message without parent_id' do
        post :create, params: { message: { recipient: 'user2', subject: 'test', body: 'test' } }
        expect(response).to be_forbidden
      end

      it 'should not create message with parent_id' do
        post :create, params: { message: { recipient: 'user2', subject: 'test', body: 'test', parent_id: 2 } }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created message as @message' do
          post :create, params: { message: @attrs }
          expect(assigns(:message)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { message: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved message as @message' do
          post :create, params: { message: @invalid_attrs }
          expect(assigns(:message)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { message: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @message = messages(:user1_to_user2_1)
      @attrs = FactoryBot.attributes_for(:message)
      @invalid_attrs = { sender_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(assigns(:message)).to be_nil
          # response.should be_missing
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "re-renders the 'edit' template" do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(assigns(:message)).to be_nil
          expect(response).to be_successful
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "re-renders the 'edit' template" do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(assigns(:message)).to be_nil
          expect(response).to be_successful
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested message as @message' do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
        end

        it "re-renders the 'edit' template" do
          expect do
            put :update, params: { id: @message.id, message: @invalid_attrs }
          end.to raise_error(ActiveRecord::RecordNotFound)
          expect(response).to be_successful
        end
      end

      it 'should not update my message' do
        put :update, params: { id: messages(:user2_to_user1_1), message: {} }
        expect(response).to be_forbidden
      end

      it "should not update other user's message" do
        expect do
          put :update, params: { id: messages(:user1_to_user2_1), message: {} }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested message as @message' do
        put :update, params: { id: messages(:user2_to_user1_1), message: {} }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'DELETE destroy' do
    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should destroy own message' do
        @message = FactoryBot.create(:message, recipient: @user.username)
        delete :destroy, params: { id: @message.id }
        expect(response).to redirect_to messages_url
      end
    end
    describe 'When logged in as User' do
      login_fixture_user

      it 'should destroy own message' do
        delete :destroy, params: { id: messages(:user2_to_user1_1) }
        expect(response).to redirect_to messages_url
        expect(response).not_to be_forbidden
      end

      it "should not destroy other user's message" do
        expect do
          delete :destroy, params: { id: messages(:user1_to_user2_1) }
        end.to raise_error(ActiveRecord::RecordNotFound)
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested message' do
        delete :destroy, params: { id: messages(:user1_to_user2_1) }
        expect(response).to redirect_to(new_user_session_url)
      end

      it 'should be redirected to new_user_session_url' do
        delete :destroy, params: { id: messages(:user1_to_user2_1) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST destroy_selected' do
    describe 'When logged in as Librarian' do
      login_fixture_librarian
      it 'should destroy own message' do
        message = FactoryBot.create(:message, recipient: @user.username)
        post :destroy_selected, params: { delete: [ message.id ] }
        expect(response).not_to be_forbidden
        expect(response).to redirect_to(messages_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user
      it 'should destroy own message' do
        message = FactoryBot.create(:message, recipient: @user.username)
        post :destroy_selected, params: { delete: [ message.id ] }
        expect(response).not_to be_forbidden
        expect(response).to redirect_to(messages_url)
      end
    end
  end
end
