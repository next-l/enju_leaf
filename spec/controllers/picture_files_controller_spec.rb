require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe PictureFilesController do
  fixtures :all
  disconnect_sunspot

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all picture_files as @picture_files' do
        get :index
        expect(assigns(:picture_files)).to eq(PictureFile.attached.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all picture_files as @picture_files' do
        get :index
        expect(assigns(:picture_files)).to eq(PictureFile.attached.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all picture_files as @picture_files' do
        get :index
        expect(assigns(:picture_files)).to eq(PictureFile.attached.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all picture_files as @picture_files' do
        get :index
        expect(assigns(:picture_files)).to eq(PictureFile.attached.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :show, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :show, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :show, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :show, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested picture_file as @picture_file' do
        get :new
        expect(assigns(:picture_file)).to be_nil
        expect(response).to redirect_to picture_files_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested picture_file as @picture_file' do
        get :new
        expect(assigns(:picture_file)).to be_nil
        expect(response).to redirect_to picture_files_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested picture_file as @picture_file' do
        get :new
        expect(assigns(:picture_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested picture_file as @picture_file' do
        get :new
        expect(assigns(:picture_file)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :edit, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :edit, params: { id: picture_file.id }
        expect(assigns(:picture_file)).to eq(picture_file)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :edit, params: { id: picture_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested picture_file as @picture_file' do
        picture_file = PictureFile.find(1)
        get :edit, params: { id: picture_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = { picture_attachable_type: 'Shelf', picture_attachable_id: 1, picture: fixture_file_upload('spinner.gif', 'image/gif') }
      @invalid_attrs = { picture_attachable_id: 'invalid', picture_attachable_type: 'Library' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created picture_file as @picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(assigns(:picture_file)).to be_valid
        end

        it 'redirects to the created picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(response).to redirect_to(picture_file_url(assigns(:picture_file)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved picture_file as @picture_file' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(assigns(:picture_file)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { picture_file: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created picture_file as @picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(assigns(:picture_file)).to be_valid
        end

        it 'redirects to the created picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(response).to redirect_to(picture_file_url(assigns(:picture_file)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved picture_file as @picture_file' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(assigns(:picture_file)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { picture_file: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created picture_file as @picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(assigns(:picture_file)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { picture_file: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved picture_file as @picture_file' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(assigns(:picture_file)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created picture_file as @picture_file' do
          post :create, params: { picture_file: @attrs }
          expect(assigns(:picture_file)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { picture_file: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved picture_file as @picture_file' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(assigns(:picture_file)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { picture_file: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @picture_file = picture_files(:picture_file_00001)
      @attrs = { picture_attachable_id: '1', picture_attachable_type: 'Manifestation' }
      @invalid_attrs = { picture_attachable_id: 'invalid', picture_attachable_type: 'Library' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
        end

        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
          expect(assigns(:picture_file)).to eq(@picture_file)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @picture_file.id, move: 'lower' }
          expect(response).to redirect_to(picture_files_url(shelf_id: @picture_file.picture_attachable_id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
        end

        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
          expect(assigns(:picture_file)).to eq(@picture_file)
          expect(response).to redirect_to(@picture_file)
        end
      end

      describe 'with invalid params' do
        it 'assigns the picture_file as @picture_file' do
          put :update, params: { id: @picture_file, picture_file: @invalid_attrs }
          expect(assigns(:picture_file)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @picture_file, picture_file: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
        end

        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
          expect(assigns(:picture_file)).to eq(@picture_file)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @picture_file.id, picture_file: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested picture_file as @picture_file' do
          put :update, params: { id: @picture_file.id, picture_file: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @picture_file = PictureFile.find(1)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested picture_file' do
        delete :destroy, params: { id: @picture_file.id }
      end

      it 'redirects to the picture_files list' do
        delete :destroy, params: { id: @picture_file.id }
        expect(response).to redirect_to(picture_files_url(shelf_id: @picture_file.picture_attachable_id))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested picture_file' do
        delete :destroy, params: { id: @picture_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @picture_file.id }
        expect(response).to redirect_to(picture_files_url(shelf_id: @picture_file.picture_attachable_id))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested picture_file' do
        delete :destroy, params: { id: @picture_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @picture_file.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested picture_file' do
        delete :destroy, params: { id: @picture_file.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @picture_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
