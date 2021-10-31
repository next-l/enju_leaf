require 'rails_helper'

describe LibrariesController do
  fixtures :all

  describe 'GET index', solr: true do
    before do
      Library.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all libraries as @libraries' do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all libraries as @libraries' do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all libraries as @libraries' do
        get :index
        assigns(:libraries).should_not be_empty
      end
    end

    describe 'When not logged in' do
      it 'assigns all libraries as @libraries' do
        get :index
        assigns(:libraries).should_not be_empty
      end

      it 'should get index with query' do
        get :index, params: { query: 'kamata' }
        response.should be_successful
        assigns(:libraries).include?(Library.friendly.find('kamata')).should be_truthy
      end
    end
  end

  describe 'GET show', solr: true do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested library as @library' do
        get :show, params: { id: 1 }
        assigns(:library).should eq(libraries(:library_00001))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested library as @library' do
        get :show, params: { id: 1 }
        assigns(:library).should eq(libraries(:library_00001))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested library as @library' do
        get :show, params: { id: 1 }
        assigns(:library).should eq(libraries(:library_00001))
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested library as @library' do
        get :show, params: { id: 1 }
        assigns(:library).should eq(libraries(:library_00001))
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested library as @library' do
        get :new
        assigns(:library).should_not be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested library as @library' do
        get :new
        assigns(:library).should be_nil
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested library as @library' do
        get :new
        assigns(:library).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested library as @library' do
        get :new
        assigns(:library).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested library as @library' do
        library = FactoryBot.create(:library)
        get :edit, params: { id: library.id }
        assigns(:library).should eq(library)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested library as @library' do
        library = FactoryBot.create(:library)
        get :edit, params: { id: library.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested library as @library' do
        library = FactoryBot.create(:library)
        get :edit, params: { id: library.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested library as @library' do
        library = FactoryBot.create(:library)
        get :edit, params: { id: library.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:library)
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created library as @library' do
          post :create, params: { library: @attrs }
          assigns(:library).should be_valid
        end

        it 'redirects to the created patron' do
          post :create, params: { library: @attrs }
          response.should redirect_to(assigns(:library))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved library as @library' do
          post :create, params: { library: @invalid_attrs }
          assigns(:library).should_not be_valid
        end

        it 'should be successful' do
          post :create, params: { library: @invalid_attrs }
          response.should be_successful
        end

        it 'should not create library without short_display_name' do
          post :create, params: { library: { name: 'fujisawa', short_display_name: '' } }
          response.should be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created library as @library' do
          post :create, params: { library: @attrs }
          assigns(:library).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { library: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved library as @library' do
          post :create, params: { library: @invalid_attrs }
          assigns(:library).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { library: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created library as @library' do
          post :create, params: { library: @attrs }
          assigns(:library).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { library: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved library as @library' do
          post :create, params: { library: @invalid_attrs }
          assigns(:library).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { library: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created library as @library' do
          post :create, params: { library: @attrs }
          assigns(:library).should be_nil
        end

        it 'should be redirected to new session url' do
          post :create, params: { library: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved library as @library' do
          post :create, params: { library: @invalid_attrs }
          assigns(:library).should be_nil
        end

        it 'should be redirected to new session url' do
          post :create, params: { library: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @library = libraries(:library_00001)
      @attrs = { name: 'example' }
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested library' do
          put :update, params: { id: @library.id, library: @attrs }
        end

        it 'assigns the requested library as @library' do
          put :update, params: { id: @library.id, library: @attrs }
          assigns(:library).should eq(@library)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @library.id, library: @attrs, move: 'lower' }
          response.should redirect_to(libraries_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested library as @library' do
          put :update, params: { id: @library.id, library: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested library' do
          put :update, params: { id: @library.id, library: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @library.id, library: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'should be forbidden' do
          put :update, params: { id: @library.id, library: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested library' do
          put :update, params: { id: @library.id, library: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @library.id, library: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'should be forbidden' do
          put :update, params: { id: @library.id, library: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested library' do
          put :update, params: { id: @library.id, library: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @library.id, library: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested library as @library' do
          put :update, params: { id: @library.id, library: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    describe 'Web' do
      before(:each) do
        @library = libraries(:library_00001)
      end

      describe 'When logged in as Administrator' do
        login_fixture_admin

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should be_forbidden
        end

        it 'should not destroy library_id 1' do
          delete :destroy, params: { id: 'web' }
          response.should be_forbidden
        end

        it 'should not destroy library that contains shelves' do
          delete :destroy, params: { id: 'kamata' }
          response.should be_forbidden
        end
      end

      describe 'When logged in as Librarian' do
        login_fixture_librarian

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should be_forbidden
        end
      end

      describe 'When logged in as User' do
        login_fixture_user

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should be_forbidden
        end
      end

      describe 'When not logged in' do
        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should redirect_to(new_user_session_url)
        end
      end
    end

    describe 'Library' do
      before(:each) do
        @library = FactoryBot.create(:library)
        @library.shelves.first.destroy
      end

      describe 'When logged in as Administrator' do
        login_fixture_admin

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'redirects to the libraries list' do
          delete :destroy, params: { id: @library.id }
          response.should redirect_to(libraries_url)
        end
      end

      describe 'When logged in as Librarian' do
        login_fixture_librarian

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should be_forbidden
        end
      end

      describe 'When logged in as User' do
        login_fixture_user

        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should be_forbidden
        end
      end

      describe 'When not logged in' do
        it 'destroys the requested library' do
          delete :destroy, params: { id: @library.id }
        end

        it 'should be forbidden' do
          delete :destroy, params: { id: @library.id }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end
end
