require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe BookstoresController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:bookstore)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:bookstore)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all bookstores as @bookstores' do
        get :index
        expect(assigns(:bookstores)).to eq(Bookstore.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all bookstores as @bookstores' do
        get :index
        expect(assigns(:bookstores)).to eq(Bookstore.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all bookstores as @bookstores' do
        get :index
        expect(assigns(:bookstores)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all bookstores as @bookstores' do
        get :index
        expect(assigns(:bookstores)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @bookstore = FactoryBot.create(:bookstore)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested bookstore as @bookstore' do
        get :show, params: { id: @bookstore.id }
        expect(assigns(:bookstore)).to eq(@bookstore)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested bookstore as @bookstore' do
        get :show, params: { id: @bookstore.id }
        expect(assigns(:bookstore)).to eq(@bookstore)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested bookstore as @bookstore' do
        get :show, params: { id: @bookstore.id }
        expect(assigns(:bookstore)).to eq(@bookstore)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested bookstore as @bookstore' do
        get :show, params: { id: @bookstore.id }
        expect(assigns(:bookstore)).to eq(@bookstore)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested bookstore as @bookstore' do
        get :new
        expect(assigns(:bookstore)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested bookstore as @bookstore' do
        get :new
        expect(assigns(:bookstore)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested bookstore as @bookstore' do
        get :new
        expect(assigns(:bookstore)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested bookstore as @bookstore' do
        get :new
        expect(assigns(:bookstore)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    before(:each) do
      @bookstore = FactoryBot.create(:bookstore)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested bookstore as @bookstore' do
        get :edit, params: { id: @bookstore.id }
        expect(assigns(:bookstore)).to eq(@bookstore)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested bookstore as @bookstore' do
        get :edit, params: { id: @bookstore.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested bookstore as @bookstore' do
        get :edit, params: { id: @bookstore.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested bookstore as @bookstore' do
        get :edit, params: { id: @bookstore.id }
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
        it 'assigns a newly created bookstore as @bookstore' do
          post :create, params: { bookstore: @attrs }
          expect(assigns(:bookstore)).to be_valid
        end

        it 'redirects to the created bookstore' do
          post :create, params: { bookstore: @attrs }
          expect(response).to redirect_to(assigns(:bookstore))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved bookstore as @bookstore' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(assigns(:bookstore)).not_to be_valid
        end

        it 'should be successful' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created bookstore as @bookstore' do
          post :create, params: { bookstore: @attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved bookstore as @bookstore' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created bookstore as @bookstore' do
          post :create, params: { bookstore: @attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved bookstore as @bookstore' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created bookstore as @bookstore' do
          post :create, params: { bookstore: @attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved bookstore as @bookstore' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(assigns(:bookstore)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { bookstore: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @bookstore = FactoryBot.create(:bookstore)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
        end

        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
          expect(assigns(:bookstore)).to eq(@bookstore)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs, move: 'lower' }
          expect(response).to redirect_to(bookstores_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
        end

        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
          expect(assigns(:bookstore)).to eq(@bookstore)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
        end

        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
          expect(assigns(:bookstore)).to eq(@bookstore)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @bookstore.id, bookstore: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested bookstore as @bookstore' do
          put :update, params: { id: @bookstore.id, bookstore: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @bookstore = FactoryBot.create(:bookstore)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested bookstore' do
        delete :destroy, params: { id: @bookstore.id }
      end

      it 'redirects to the bookstores list' do
        delete :destroy, params: { id: @bookstore.id }
        expect(response).to redirect_to(bookstores_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested bookstore' do
        delete :destroy, params: { id: @bookstore.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @bookstore.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested bookstore' do
        delete :destroy, params: { id: @bookstore.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @bookstore.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested bookstore' do
        delete :destroy, params: { id: @bookstore.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @bookstore.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
