require 'rails_helper'

describe UserImportResultsController do
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all user_import_results as @user_import_results' do
        get :index
        expect(assigns(:user_import_results)).to eq(UserImportResult.page(1))
      end

      describe 'With @user_import_file parameter' do
        before(:each) do
          @file = UserImportFile.create attachment: fixture_file_upload("user_import_file_sample_long.tsv"), user: users(:admin)
          @file.default_user_group = UserGroup.find(2)
          @file.default_library = Library.find(3)
          @file.save
          @file.import_start
        end
        render_views
        it 'should assign all user_import_results for the user_import_file with a page parameter' do
          get :index, params: { user_import_file_id: @file.id }
          results = assigns(:user_import_results)
          expect(results).not_to be_empty
          expect(response.body).to match /<td>11<\/td>/
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all user_import_results as @user_import_results' do
        get :index
        expect(assigns(:user_import_results)).to eq(UserImportResult.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns empty as @user_import_results' do
        get :index
        expect(assigns(:user_import_results)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @user_import_results' do
        get :index
        expect(assigns(:user_import_results)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested user_import_result as @user_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:user_import_result)).to eq(UserImportResult.find(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested user_import_result as @user_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:user_import_result)).to eq(UserImportResult.find(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested user_import_result as @user_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:user_import_result)).to eq(UserImportResult.find(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested user_import_result as @user_import_result' do
        get :show, params: { id: 1 }
        expect(assigns(:user_import_result)).to eq(UserImportResult.find(1))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @user_import_result = user_import_results(:one)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested user_import_result' do
        delete :destroy, params: { id: @user_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested user_import_result' do
        delete :destroy, params: { id: @user_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested user_import_result' do
        delete :destroy, params: { id: @user_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_import_result.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested user_import_result' do
        delete :destroy, params: { id: @user_import_result.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @user_import_result.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
