require 'rails_helper'

describe SubscribesController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:subscribe)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:subscribe)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all subscribes as @subscribes' do
        get :index
        assigns(:subscribes).should eq(Subscribe.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all subscribes as @subscribes' do
        get :index
        assigns(:subscribes).should eq(Subscribe.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should be forbidden' do
        get :index
        assigns(:subscribes).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all subscribes as @subscribes' do
        get :index
        assigns(:subscribes).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :show, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :show, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :show, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :show, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscribe as @subscribe' do
        get :new
        assigns(:subscribe).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscribe as @subscribe' do
        get :new
        assigns(:subscribe).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested subscribe as @subscribe' do
        get :new
        assigns(:subscribe).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subscribe as @subscribe' do
        get :new
        assigns(:subscribe).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :edit, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :edit, params: { id: subscribe.id }
        assigns(:subscribe).should eq(subscribe)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :edit, params: { id: subscribe.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested subscribe as @subscribe' do
        subscribe = FactoryBot.create(:subscribe)
        get :edit, params: { id: subscribe.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { work_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created subscribe as @subscribe' do
          post :create, params: { subscribe: @attrs }
          assigns(:subscribe).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { subscribe: @attrs }
          response.should redirect_to(assigns(:subscribe))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscribe as @subscribe' do
          post :create, params: { subscribe: @invalid_attrs }
          assigns(:subscribe).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { subscribe: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created subscribe as @subscribe' do
          post :create, params: { subscribe: @attrs }
          assigns(:subscribe).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { subscribe: @attrs }
          response.should redirect_to(assigns(:subscribe))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscribe as @subscribe' do
          post :create, params: { subscribe: @invalid_attrs }
          assigns(:subscribe).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { subscribe: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created subscribe as @subscribe' do
          post :create, params: { subscribe: @attrs }
          assigns(:subscribe).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscribe: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscribe as @subscribe' do
          post :create, params: { subscribe: @invalid_attrs }
          assigns(:subscribe).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscribe: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created subscribe as @subscribe' do
          post :create, params: { subscribe: @attrs }
          assigns(:subscribe).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscribe: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved subscribe as @subscribe' do
          post :create, params: { subscribe: @invalid_attrs }
          assigns(:subscribe).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { subscribe: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @subscribe = FactoryBot.create(:subscribe)
      @attrs = valid_attributes
      @invalid_attrs = { work_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
        end

        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
          assigns(:subscribe).should eq(@subscribe)
          response.should redirect_to(@subscribe)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
        end

        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
          assigns(:subscribe).should eq(@subscribe)
          response.should redirect_to(@subscribe)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
        end

        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
          assigns(:subscribe).should eq(@subscribe)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @subscribe.id, subscribe: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested subscribe as @subscribe' do
          put :update, params: { id: @subscribe.id, subscribe: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @subscribe = FactoryBot.create(:subscribe)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested subscribe' do
        delete :destroy, params: { id: @subscribe.id }
      end

      it 'redirects to the subscribes list' do
        delete :destroy, params: { id: @subscribe.id }
        response.should redirect_to(subscribes_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested subscribe' do
        delete :destroy, params: { id: @subscribe.id }
      end

      it 'redirects to the subscribes list' do
        delete :destroy, params: { id: @subscribe.id }
        response.should redirect_to(subscribes_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested subscribe' do
        delete :destroy, params: { id: @subscribe.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subscribe.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested subscribe' do
        delete :destroy, params: { id: @subscribe.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @subscribe.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
