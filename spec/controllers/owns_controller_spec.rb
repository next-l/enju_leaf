require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe OwnsController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:own)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:own)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all owns as @owns' do
        get :index
        expect(assigns(:owns)).to eq(Own.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all owns as @owns' do
        get :index
        expect(assigns(:owns)).to eq(Own.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all owns as @owns' do
        get :index
        expect(assigns(:owns)).to eq(Own.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all owns as @owns' do
        get :index
        expect(assigns(:owns)).to eq(Own.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :show, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :show, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :show, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :show, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested own as @own' do
        get :new
        expect(assigns(:own)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested own as @own' do
        get :new
        expect(assigns(:own)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested own as @own' do
        get :new
        expect(assigns(:own)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested own as @own' do
        get :new
        expect(assigns(:own)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :edit, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :edit, params: { id: own.id }
        expect(assigns(:own)).to eq(own)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested own as @own' do
        own = FactoryBot.create(:own)
        get :edit, params: { id: own.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested own as @own' do
        own = FactoryBot.create(:own)
        get :edit, params: { id: own.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { item_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created own as @own' do
          post :create, params: { own: @attrs }
          expect(assigns(:own)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { own: @attrs }
          expect(response).to redirect_to(assigns(:own))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved own as @own' do
          post :create, params: { own: @invalid_attrs }
          expect(assigns(:own)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { own: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created own as @own' do
          post :create, params: { own: @attrs }
          expect(assigns(:own)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { own: @attrs }
          expect(response).to redirect_to(assigns(:own))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved own as @own' do
          post :create, params: { own: @invalid_attrs }
          expect(assigns(:own)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { own: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created own as @own' do
          post :create, params: { own: @attrs }
          expect(assigns(:own)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { own: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved own as @own' do
          post :create, params: { own: @invalid_attrs }
          expect(assigns(:own)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { own: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created own as @own' do
          post :create, params: { own: @attrs }
          expect(assigns(:own)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { own: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved own as @own' do
          post :create, params: { own: @invalid_attrs }
          expect(assigns(:own)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { own: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @own = FactoryBot.create(:own)
      @attrs = valid_attributes
      @invalid_attrs = { item_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested own' do
          put :update, params: { id: @own.id, own: @attrs }
        end

        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @attrs }
          expect(assigns(:own)).to eq(@own)
          expect(response).to redirect_to(@own)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @own.id, own: @attrs, item_id: @own.item.id, move: 'lower' }
          expect(response).to redirect_to(owns_url(item_id: @own.item_id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested own' do
          put :update, params: { id: @own.id, own: @attrs }
        end

        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @attrs }
          expect(assigns(:own)).to eq(@own)
          expect(response).to redirect_to(@own)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested own' do
          put :update, params: { id: @own.id, own: @attrs }
        end

        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @attrs }
          expect(assigns(:own)).to eq(@own)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested own' do
          put :update, params: { id: @own.id, own: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @own.id, own: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested own as @own' do
          put :update, params: { id: @own.id, own: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @own = FactoryBot.create(:own)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested own' do
        delete :destroy, params: { id: @own.id }
      end

      it 'redirects to the owns list' do
        delete :destroy, params: { id: @own.id }
        expect(response).to redirect_to(owns_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested own' do
        delete :destroy, params: { id: @own.id }
      end

      it 'redirects to the owns list' do
        delete :destroy, params: { id: @own.id }
        expect(response).to redirect_to(owns_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested own' do
        delete :destroy, params: { id: @own.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @own.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested own' do
        delete :destroy, params: { id: @own.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @own.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
