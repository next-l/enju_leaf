require 'rails_helper'

describe ResourceImportFilesController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all resource_import_files as @resource_import_files' do
        get :index
        expect(assigns(:resource_import_files)).to eq(ResourceImportFile.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all resource_import_files as @resource_import_files' do
        get :index
        expect(assigns(:resource_import_files)).to eq(ResourceImportFile.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns empty as @resource_import_files' do
        get :index
        expect(assigns(:resource_import_files)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @resource_import_files' do
        get :index
        expect(assigns(:resource_import_files)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_import_file as @resource_import_file' do
        get :show, params: { id: resource_import_files(:resource_import_file_00003).id }
        expect(assigns(:resource_import_file)).to eq(resource_import_files(:resource_import_file_00003))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested resource_import_file as @resource_import_file' do
        get :show, params: { id: resource_import_files(:resource_import_file_00003).id }
        expect(assigns(:resource_import_file)).to eq(resource_import_files(:resource_import_file_00003))
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested resource_import_file as @resource_import_file' do
        get :show, params: { id: resource_import_files(:resource_import_file_00003).id }
        expect(assigns(:resource_import_file)).to eq(resource_import_files(:resource_import_file_00003))
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested resource_import_file as @resource_import_file' do
        get :show, params: { id: resource_import_files(:resource_import_file_00003).id }
        expect(assigns(:resource_import_file)).to eq(resource_import_files(:resource_import_file_00003))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_import_file as @resource_import_file' do
        get :new
        expect(assigns(:resource_import_file)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested resource_import_file as @resource_import_file' do
        get :new
        expect(assigns(:resource_import_file)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested resource_import_file as @resource_import_file' do
        get :new
        expect(assigns(:resource_import_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested resource_import_file as @resource_import_file' do
        get :new
        expect(assigns(:resource_import_file)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    describe 'When logged in as Librarian' do
      before(:each) do
        @user = users(:librarian1)
        sign_in @user
      end

      it 'should create resource_import_file' do
        post :create, params: { resource_import_file: { resource_import: fixture_file_upload('resource_import_file_sample1.tsv', 'text/csv'), edit_mode: 'create', default_shelf_id: 1 } }
        expect(assigns(:resource_import_file)).to be_valid
        assigns(:resource_import_file).user.username.should eq @user.username
        expect(response).to redirect_to resource_import_file_url(assigns(:resource_import_file))
      end

      it 'should not create resource_import_file without default_shelf_id' do
        post :create, params: { resource_import_file: { resource_import: fixture_file_upload('resource_import_file_sample1.tsv', 'text/csv'), edit_mode: 'create' } }
        expect(assigns(:resource_import_file)).not_to be_valid
        assigns(:resource_import_file).user.username.should eq @user.username
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        @user = users(:user1)
        sign_in @user
      end

      it 'should be forbidden' do
        post :create, params: { resource_import_file: { resource_import: fixture_file_upload('resource_import_file_sample1.tsv', 'text/csv') } }
        assigns(:resource_import_file).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should be redirected to new session url' do
        post :create, params: { resource_import_file: { resource_import: fixture_file_upload('resource_import_file_sample1.tsv', 'text/csv') } }
        assigns(:resource_import_file).should be_nil
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_import_file as @resource_import_file' do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, params: { id: resource_import_file.id }
        expect(assigns(:resource_import_file)).to eq(resource_import_file)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested resource_import_file as @resource_import_file' do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, params: { id: resource_import_file.id }
        expect(assigns(:resource_import_file)).to eq(resource_import_file)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested resource_import_file as @resource_import_file' do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, params: { id: resource_import_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested resource_import_file as @resource_import_file' do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, params: { id: resource_import_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'PUT update' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'should update resource_import_file' do
        put :update, params: { id: resource_import_files(:resource_import_file_00003).id, resource_import_file: { mode: 'update' } }
        expect(response).to redirect_to resource_import_file_url(assigns(:resource_import_file))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should update resource_import_file' do
        put :update, params: { id: resource_import_files(:resource_import_file_00003).id, resource_import_file: { mode: 'update' } }
        expect(response).to redirect_to resource_import_file_url(assigns(:resource_import_file))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not update resource_import_file' do
        put :update, params: { id: resource_import_files(:resource_import_file_00003).id, resource_import_file: { mode: 'update' } }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not update resource_import_file' do
        put :update, params: { id: resource_import_files(:resource_import_file_00003).id, resource_import_file: { mode: 'update' } }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @resource_import_file = resource_import_files(:resource_import_file_00001)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested resource_import_file' do
        delete :destroy, params: { id: @resource_import_file.id }
      end

      it 'redirects to the resource_import_files list' do
        delete :destroy, params: { id: @resource_import_file.id }
        expect(response).to redirect_to(resource_import_files_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested resource_import_file' do
        delete :destroy, params: { id: @resource_import_file.id }
      end

      it 'redirects to the resource_import_files list' do
        delete :destroy, params: { id: @resource_import_file.id }
        expect(response).to redirect_to(resource_import_files_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested resource_import_file' do
        delete :destroy, params: { id: @resource_import_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested resource_import_file' do
        delete :destroy, params: { id: @resource_import_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
