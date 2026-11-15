require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe SearchEnginesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:search_engine)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:search_engine)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all search_engines as @search_engines' do
        get :index
        expect(assigns(:search_engines)).to eq(SearchEngine.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all search_engines as @search_engines' do
        get :index
        expect(assigns(:search_engines)).to eq(SearchEngine.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all search_engines as @search_engines' do
        get :index
        expect(assigns(:search_engines)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all search_engines as @search_engines' do
        get :index
        expect(assigns(:search_engines)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :show, params: { id: search_engine.id }
        expect(assigns(:search_engine)).to eq(search_engine)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :show, params: { id: search_engine.id }
        expect(assigns(:search_engine)).to eq(search_engine)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :show, params: { id: search_engine.id }
        expect(assigns(:search_engine)).to eq(search_engine)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :show, params: { id: search_engine.id }
        expect(assigns(:search_engine)).to eq(search_engine)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested search_engine as @search_engine' do
        get :new
        expect(assigns(:search_engine)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested search_engine as @search_engine' do
        get :new
        expect(assigns(:search_engine)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested search_engine as @search_engine' do
        get :new
        expect(assigns(:search_engine)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested search_engine as @search_engine' do
        get :new
        expect(assigns(:search_engine)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :edit, params: { id: search_engine.id }
        expect(assigns(:search_engine)).to eq(search_engine)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :edit, params: { id: search_engine.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :edit, params: { id: search_engine.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested search_engine as @search_engine' do
        search_engine = FactoryBot.create(:search_engine)
        get :edit, params: { id: search_engine.id }
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
        it 'assigns a newly created search_engine as @search_engine' do
          post :create, params: { search_engine: @attrs }
          expect(assigns(:search_engine)).to be_valid
        end

        it 'redirects to the created patron' do
          post :create, params: { search_engine: @attrs }
          expect(response).to redirect_to(assigns(:search_engine))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved search_engine as @search_engine' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(assigns(:search_engine)).not_to be_valid
        end

        it 'should be successful' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created search_engine as @search_engine' do
          post :create, params: { search_engine: @attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved search_engine as @search_engine' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created search_engine as @search_engine' do
          post :create, params: { search_engine: @attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved search_engine as @search_engine' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created search_engine as @search_engine' do
          post :create, params: { search_engine: @attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved search_engine as @search_engine' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(assigns(:search_engine)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { search_engine: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @search_engine = FactoryBot.create(:search_engine)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
        end

        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
          expect(assigns(:search_engine)).to eq(@search_engine)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs, move: 'lower' }
          expect(response).to redirect_to(search_engines_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
        end

        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
          expect(assigns(:search_engine)).to eq(@search_engine)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
        end

        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
          expect(assigns(:search_engine)).to eq(@search_engine)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @search_engine.id, search_engine: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested search_engine as @search_engine' do
          put :update, params: { id: @search_engine.id, search_engine: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @search_engine = FactoryBot.create(:search_engine)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested search_engine' do
        delete :destroy, params: { id: @search_engine.id }
      end

      it 'redirects to the search_engines list' do
        delete :destroy, params: { id: @search_engine.id }
        expect(response).to redirect_to(search_engines_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested search_engine' do
        delete :destroy, params: { id: @search_engine.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @search_engine.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested search_engine' do
        delete :destroy, params: { id: @search_engine.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @search_engine.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested search_engine' do
        delete :destroy, params: { id: @search_engine.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @search_engine.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
