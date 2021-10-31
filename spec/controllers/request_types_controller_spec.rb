require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe RequestTypesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:request_status_type)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:request_type)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all request_types as @request_types' do
        get :index
        assigns(:request_types).should eq(RequestType.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all request_types as @request_types' do
        get :index
        assigns(:request_types).should eq(RequestType.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign request_types as @request_types' do
        get :index
        assigns(:request_types).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign request_types as @request_types' do
        get :index
        assigns(:request_types).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @request_type = FactoryBot.create(:request_type)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested request_type as @request_type' do
        get :show, params: { id: @request_type.id }
        assigns(:request_type).should eq(@request_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested request_type as @request_type' do
        get :show, params: { id: @request_type.id }
        assigns(:request_type).should eq(@request_type)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested request_type as @request_type' do
        get :show, params: { id: @request_type.id }
        assigns(:request_type).should eq(@request_type)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested request_type as @request_type' do
        get :show, params: { id: @request_type.id }
        assigns(:request_type).should eq(@request_type)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested request_type as @request_type' do
        get :new
        assigns(:request_type).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested request_type as @request_type' do
        get :new
        assigns(:request_type).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested request_type as @request_type' do
        get :new
        assigns(:request_type).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested request_type as @request_type' do
        get :new
        assigns(:request_type).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    before(:each) do
      @request_type = FactoryBot.create(:request_type)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested request_type as @request_type' do
        get :edit, params: { id: @request_type.id }
        assigns(:request_type).should eq(@request_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested request_type as @request_type' do
        get :edit, params: { id: @request_type.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested request_type as @request_type' do
        get :edit, params: { id: @request_type.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested request_type as @request_type' do
        get :edit, params: { id: @request_type.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created request_type as @request_type' do
          post :create, params: { request_type: @attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved request_type as @request_type' do
          post :create, params: { request_type: @invalid_attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created request_type as @request_type' do
          post :create, params: { request_type: @attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved request_type as @request_type' do
          post :create, params: { request_type: @invalid_attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created request_type as @request_type' do
          post :create, params: { request_type: @attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved request_type as @request_type' do
          post :create, params: { request_type: @invalid_attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created request_type as @request_type' do
          post :create, params: { request_type: @attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved request_type as @request_type' do
          post :create, params: { request_type: @invalid_attrs }
          assigns(:request_type).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { request_type: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @request_type = FactoryBot.create(:request_type)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
        end

        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
          assigns(:request_type).should eq(@request_type)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @request_type.id, request_type: @attrs, move: 'lower' }
          response.should redirect_to(request_types_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
        end

        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
          assigns(:request_type).should eq(@request_type)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
        end

        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
          assigns(:request_type).should eq(@request_type)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested request_type' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @request_type.id, request_type: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested request_type as @request_type' do
          put :update, params: { id: @request_type.id, request_type: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @request_type = FactoryBot.create(:request_type)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested request_type' do
        delete :destroy, params: { id: @request_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @request_type.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested request_type' do
        delete :destroy, params: { id: @request_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @request_type.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested request_type' do
        delete :destroy, params: { id: @request_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @request_type.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested request_type' do
        delete :destroy, params: { id: @request_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @request_type.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
