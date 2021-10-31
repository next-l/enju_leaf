require 'rails_helper'

describe ResourceExportFilesController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all resource_export_files as @resource_export_files' do
        get :index
        expect(assigns(:resource_export_files)).to eq(ResourceExportFile.order('id DESC').page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all resource_export_files as @resource_export_files' do
        get :index
        expect(assigns(:resource_export_files)).to eq(ResourceExportFile.order('id DESC').page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns empty as @resource_export_files' do
        get :index
        expect(assigns(:resource_export_files)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @resource_export_files' do
        get :index
        expect(assigns(:resource_export_files)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_export_file as @resource_export_file' do
        get :show, params: { id: resource_export_files(:resource_export_file_00003).id }
        expect(assigns(:resource_export_file)).to eq(resource_export_files(:resource_export_file_00003))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested resource_export_file as @resource_export_file' do
        get :show, params: { id: resource_export_files(:resource_export_file_00003).id }
        expect(assigns(:resource_export_file)).to eq(resource_export_files(:resource_export_file_00003))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested resource_export_file as @resource_export_file' do
        get :show, params: { id: resource_export_files(:resource_export_file_00003).id }
        expect(assigns(:resource_export_file)).to eq(resource_export_files(:resource_export_file_00003))
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested resource_export_file as @resource_export_file' do
        get :show, params: { id: resource_export_files(:resource_export_file_00003).id }
        expect(assigns(:resource_export_file)).to eq(resource_export_files(:resource_export_file_00003))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_export_file as @resource_export_file' do
        get :new
        expect(assigns(:resource_export_file)).to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested resource_export_file as @resource_export_file' do
        get :new
        expect(assigns(:resource_export_file)).to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested resource_export_file as @resource_export_file' do
        get :new
        expect(assigns(:resource_export_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested resource_export_file as @resource_export_file' do
        get :new
        expect(assigns(:resource_export_file)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should create agent_export_file' do
        post :create, params: { resource_export_file: { mode: 'export' } }
        expect(assigns(:resource_export_file)).to be_valid
        assigns(:resource_export_file).user.username.should eq @user.username
        expect(response).to redirect_to resource_export_file_url(assigns(:resource_export_file))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should be forbidden' do
        post :create, params: { resource_export_file: { mode: 'export' } }
        assigns(:resource_export_file).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should be redirected to new session url' do
        post :create, params: { resource_export_file: { mode: 'export' } }
        assigns(:resource_export_file).should be_nil
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_export_file as @resource_export_file' do
        resource_export_file = resource_export_files(:resource_export_file_00001)
        get :edit, params: { id: resource_export_file.id }
        expect(assigns(:resource_export_file)).to eq(resource_export_file)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested resource_export_file as @resource_export_file' do
        resource_export_file = resource_export_files(:resource_export_file_00001)
        get :edit, params: { id: resource_export_file.id }
        expect(assigns(:resource_export_file)).to eq(resource_export_file)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested resource_export_file as @resource_export_file' do
        resource_export_file = resource_export_files(:resource_export_file_00001)
        get :edit, params: { id: resource_export_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested resource_export_file as @resource_export_file' do
        resource_export_file = resource_export_files(:resource_export_file_00001)
        get :edit, params: { id: resource_export_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'PUT update' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should update resource_export_file' do
        put :update, params: { id: resource_export_files(:resource_export_file_00003).id, resource_export_file: { mode: 'export' } }
        expect(response).to redirect_to resource_export_file_url(assigns(:resource_export_file))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should update resource_export_file' do
        put :update, params: { id: resource_export_files(:resource_export_file_00003).id, resource_export_file: { mode: 'export' } }
        expect(response).to redirect_to resource_export_file_url(assigns(:resource_export_file))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not update resource_export_file' do
        put :update, params: { id: resource_export_files(:resource_export_file_00003).id, resource_export_file: { mode: 'export' } }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not update resource_export_file' do
        put :update, params: { id: resource_export_files(:resource_export_file_00003).id, resource_export_file: { mode: 'export' } }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @resource_export_file = resource_export_files(:resource_export_file_00001)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested resource_export_file' do
        delete :destroy, params: { id: @resource_export_file.id }
      end

      it 'redirects to the resource_export_files list' do
        delete :destroy, params: { id: @resource_export_file.id }
        expect(response).to redirect_to(resource_export_files_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested resource_export_file' do
        delete :destroy, params: { id: @resource_export_file.id }
      end

      it 'redirects to the resource_export_files list' do
        delete :destroy, params: { id: @resource_export_file.id }
        expect(response).to redirect_to(resource_export_files_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested resource_export_file' do
        delete :destroy, params: { id: @resource_export_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_export_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested resource_export_file' do
        delete :destroy, params: { id: @resource_export_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_export_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
