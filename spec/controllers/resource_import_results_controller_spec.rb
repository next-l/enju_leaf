require 'rails_helper'

describe ResourceImportResultsController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all resource_import_results as @resource_import_results' do
        get :index
        expect(assigns(:resource_import_results)).to eq(ResourceImportResult.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all resource_import_results as @resource_import_results' do
        get :index
        expect(assigns(:resource_import_results)).to eq(ResourceImportResult.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns empty as @resource_import_results' do
        get :index
        expect(assigns(:resource_import_results)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @resource_import_results' do
        get :index
        expect(assigns(:resource_import_results)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested resource_import_result as @resource_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:resource_import_result)).to eq(ResourceImportResult.find(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested resource_import_result as @resource_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:resource_import_result)).to eq(ResourceImportResult.find(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested resource_import_result as @resource_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:resource_import_result)).to eq(ResourceImportResult.find(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested resource_import_result as @resource_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:resource_import_result)).to eq(ResourceImportResult.find(1))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @resource_import_result = resource_import_results(:one)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested resource_import_result' do
        delete :destroy, params: { id: @resource_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested resource_import_result' do
        delete :destroy, params: { id: @resource_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested resource_import_result' do
        delete :destroy, params: { id: @resource_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested resource_import_result' do
        delete :destroy, params: { id: @resource_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @resource_import_result.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
