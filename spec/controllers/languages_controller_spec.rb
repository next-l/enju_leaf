require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe LanguagesController do
  disconnect_sunspot
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:language)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:language)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all languages as @languages' do
        get :index
        expect(assigns(:languages)).to eq(Language.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all languages as @languages' do
        get :index
        expect(assigns(:languages)).to eq(Language.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all languages as @languages' do
        get :index
        expect(assigns(:languages)).to eq(Language.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all languages as @languages' do
        get :index
        expect(assigns(:languages)).to eq(Language.page(1))
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @language = FactoryBot.create(:language)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested language as @language' do
        get :show, params: { id: @language.id }
        expect(assigns(:language)).to eq(@language)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested language as @language' do
        get :show, params: { id: @language.id }
        expect(assigns(:language)).to eq(@language)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested language as @language' do
        get :new
        expect(assigns(:language)).to_not be_valid
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested language as @language' do
        get :new
        expect(assigns(:language)).to be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    before(:each) do
      @language = FactoryBot.create(:language)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested language as @language' do
        get :edit, params: { id: @language.id }
        expect(assigns(:language)).to eq(@language)
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested language as @language' do
        get :edit, params: { id: @language.id }
        response.should redirect_to(new_user_session_url)
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
        it 'assigns a newly created language as @language' do
          post :create, params: { language: @attrs }
          expect(assigns(:language)).to be_valid
        end

        it 'redirects to the created language' do
          post :create, params: { language: @attrs }
          response.should redirect_to(assigns(:language))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved language as @language' do
          post :create, params: { language: @invalid_attrs }
          expect(assigns(:language)).to_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { language: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created language as @language' do
          post :create, params: { language: @attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved language as @language' do
          post :create, params: { language: @invalid_attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created language as @language' do
          post :create, params: { language: @attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved language as @language' do
          post :create, params: { language: @invalid_attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created language as @language' do
          post :create, params: { language: @attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved language as @language' do
          post :create, params: { language: @invalid_attrs }
          expect(assigns(:language)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { language: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @language = FactoryBot.create(:language)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested language' do
          put :update, params: { id: @language.id, language: @attrs }
        end

        it 'assigns the requested language as @language' do
          put :update, params: { id: @language.id, language: @attrs }
          expect(assigns(:language)).to eq(@language)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @language.id, language: @attrs, move: 'lower' }
          response.should redirect_to(languages_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested language as @language' do
          put :update, params: { id: @language.id, language: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested language' do
          put :update, params: { id: @language.id, language: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @language.id, language: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested language as @language' do
          put :update, params: { id: @language.id, language: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @language = FactoryBot.create(:language)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested language' do
        delete :destroy, params: { id: @language.id }
      end

      it 'redirects to the languagees list' do
        delete :destroy, params: { id: @language.id }
        response.should redirect_to(languages_url)
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested language' do
        delete :destroy, params: { id: @language.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @language.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
