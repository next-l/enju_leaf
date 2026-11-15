require 'rails_helper'

describe ShelvesController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:shelf)
  end

  describe 'GET index', solr: true do
    before do
      Shelf.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all shelves as @shelves' do
        get :index
        expect(assigns(:shelves)).not_to be_empty
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all shelves as @shelves' do
        get :index
        expect(assigns(:shelves)).not_to be_empty
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all shelves as @shelves' do
        get :index
        expect(assigns(:shelves)).not_to be_empty
      end
    end

    describe 'When not logged in' do
      it 'assigns all shelves as @shelves' do
        get :index
        expect(assigns(:shelves)).not_to be_empty
        expect(response).to be_successful
      end

      it 'assigns all shelves as @shelves with library_id' do
        get :index, params: { library_id: 'kamata' }
        expect(assigns(:shelves).map(&:id)).to eq(Library.friendly.find('kamata').shelves.order(:position).page(1).pluck(:id))
        expect(response).to be_successful
      end

      it 'assigns all shelves as @shelves with select mode' do
        get :index, params: { mode: 'select' }
        expect(assigns(:shelves)).to eq(Shelf.real.order(:position))
        expect(response).to be_successful
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested shelf as @shelf' do
        get :show, params: { id: 1 }
        expect(assigns(:shelf)).to eq(Shelf.find(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested shelf as @shelf' do
        get :show, params: { id: 1 }
        expect(assigns(:shelf)).to eq(Shelf.find(1))
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested shelf as @shelf' do
        get :new
        expect(assigns(:shelf)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested shelf as @shelf' do
        get :new
        expect(assigns(:shelf)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested shelf as @shelf' do
        get :new
        expect(assigns(:shelf)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested shelf as @shelf' do
        get :new
        expect(assigns(:shelf)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested shelf as @shelf' do
        shelf = FactoryBot.create(:shelf)
        get :edit, params: { id: shelf.id }
        expect(assigns(:shelf)).to eq(shelf)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested shelf as @shelf' do
        shelf = FactoryBot.create(:shelf)
        get :edit, params: { id: shelf.id }
        expect(assigns(:shelf)).to eq(shelf)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested shelf as @shelf' do
        shelf = FactoryBot.create(:shelf)
        get :edit, params: { id: shelf.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested shelf as @shelf' do
        shelf = FactoryBot.create(:shelf)
        get :edit, params: { id: shelf.id }
        expect(response).to redirect_to(new_user_session_url)
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
        it 'assigns a newly created shelf as @shelf' do
          post :create, params: { shelf: @attrs }
          expect(assigns(:shelf)).to be_valid
        end

        it 'redirects to the created patron' do
          post :create, params: { shelf: @attrs }
          expect(response).to redirect_to(assigns(:shelf))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved shelf as @shelf' do
          post :create, params: { shelf: @invalid_attrs }
          expect(assigns(:shelf)).not_to be_valid
        end

        it 'should be successful' do
          post :create, params: { shelf: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created shelf as @shelf' do
          post :create, params: { shelf: @attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved shelf as @shelf' do
          post :create, params: { shelf: @invalid_attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created shelf as @shelf' do
          post :create, params: { shelf: @attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved shelf as @shelf' do
          post :create, params: { shelf: @invalid_attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created shelf as @shelf' do
          post :create, params: { shelf: @attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved shelf as @shelf' do
          post :create, params: { shelf: @invalid_attrs }
          expect(assigns(:shelf)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { shelf: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @shelf = FactoryBot.create(:shelf)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
        end

        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
          expect(assigns(:shelf)).to eq(@shelf)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @shelf.id, shelf: @attrs, move: 'lower' }
          expect(response).to redirect_to(shelves_url(library_id: @shelf.library_id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
        end

        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
          expect(assigns(:shelf)).to eq(@shelf)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
        end

        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
          expect(assigns(:shelf)).to eq(@shelf)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested shelf' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @shelf.id, shelf: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested shelf as @shelf' do
          put :update, params: { id: @shelf.id, shelf: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @shelf = FactoryBot.create(:shelf)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested shelf' do
        delete :destroy, params: { id: @shelf.id }
      end

      it 'redirects to the shelves list' do
        delete :destroy, params: { id: @shelf.id }
        expect(response).to redirect_to(shelves_url)
      end

      it 'should not destroy a shelf that has id 1' do
        delete :destroy, params: { id: 1 }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested shelf' do
        delete :destroy, params: { id: @shelf.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @shelf.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested shelf' do
        delete :destroy, params: { id: @shelf.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @shelf.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested shelf' do
        delete :destroy, params: { id: @shelf.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @shelf.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
