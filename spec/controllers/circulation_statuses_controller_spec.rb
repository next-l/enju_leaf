require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe CirculationStatusesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:circulation_status)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:circulation_status)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all circulation_statuses as @circulation_statuses' do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all circulation_statuses as @circulation_statuses' do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all circulation_statuses as @circulation_statuses' do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.order(:position))
      end
    end

    describe 'When not logged in' do
      it 'assigns all circulation_statuses as @circulation_statuses' do
        get :index
        assigns(:circulation_statuses).should eq(CirculationStatus.order(:position))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :show, params: { id: circulation_status.id }
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :show, params: { id: circulation_status.id }
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :show, params: { id: circulation_status.id }
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :show, params: { id: circulation_status.id }
        assigns(:circulation_status).should eq(circulation_status)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should be forbidden' do
        get :new
        assigns(:circulation_status).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should be forbidden' do
        get :new
        assigns(:circulation_status).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should be forbidden' do
        get :new
        assigns(:circulation_status).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should be redirected' do
        get :new
        assigns(:circulation_status).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :edit, params: { id: circulation_status.id }
        assigns(:circulation_status).should eq(circulation_status)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :edit, params: { id: circulation_status.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :edit, params: { id: circulation_status.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested circulation_status as @circulation_status' do
        circulation_status = FactoryBot.create(:circulation_status)
        get :edit, params: { id: circulation_status.id }
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
        it 'assigns a newly created circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'redirects to the created patron' do
          post :create, params: { circulation_status: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @invalid_attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be successful' do
          post :create, params: { circulation_status: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @invalid_attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @invalid_attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved circulation_status as @circulation_status' do
          post :create, params: { circulation_status: @invalid_attrs }
          assigns(:circulation_status).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { circulation_status: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @circulation_status = FactoryBot.create(:circulation_status)
      @attrs = valid_attributes
      @invalid_attrs = { display_name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
        end

        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
          assigns(:circulation_status).should eq(@circulation_status)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs, move: 'lower' }
          response.should redirect_to(circulation_statuses_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
        end

        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
          assigns(:circulation_status).should eq(@circulation_status)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
        end

        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
          assigns(:circulation_status).should eq(@circulation_status)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @circulation_status.id, circulation_status: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested circulation_status as @circulation_status' do
          put :update, params: { id: @circulation_status.id, circulation_status: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @circulation_status = FactoryBot.create(:circulation_status)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested circulation_status' do
        delete :destroy, params: { id: @circulation_status.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @circulation_status.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested circulation_status' do
        delete :destroy, params: { id: @circulation_status.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @circulation_status.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested circulation_status' do
        delete :destroy, params: { id: @circulation_status.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @circulation_status.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested circulation_status' do
        delete :destroy, params: { id: @circulation_status.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @circulation_status.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
