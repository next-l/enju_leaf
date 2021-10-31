require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe CountriesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:country)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:country)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all countries as @countries' do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all countries as @countries' do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all countries as @countries' do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all countries as @countries' do
        get :index
        assigns(:countries).should eq(Country.page(1))
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @country = FactoryBot.create(:country)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested country as @country' do
        get :show, params: { id: @country.id }
        assigns(:country).should eq(@country)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested country as @country' do
        get :show, params: { id: @country.id }
        assigns(:country).should eq(@country)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested country as @country' do
        get :show, params: { id: @country.id }
        assigns(:country).should eq(@country)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested country as @country' do
        get :show, params: { id: @country.id }
        assigns(:country).should eq(@country)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested country as @country' do
        get :new
        assigns(:country).should_not be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested country as @country' do
        get :new
        assigns(:country).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested country as @country' do
        get :new
        assigns(:country).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested country as @country' do
        get :new
        assigns(:country).should be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested country as @country' do
        country = FactoryBot.create(:country)
        get :edit, params: { id: country.id }
        assigns(:country).should eq(country)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested country as @country' do
        country = FactoryBot.create(:country)
        get :edit, params: { id: country.id }
        assigns(:country).should eq(country)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested country as @country' do
        country = FactoryBot.create(:country)
        get :edit, params: { id: country.id }
        assigns(:country).should eq(country)
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested country as @country' do
        country = FactoryBot.create(:country)
        get :edit, params: { id: country.id }
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
        it 'assigns a newly created country as @country' do
          post :create, params: { country: @attrs }
          assigns(:country).should be_valid
        end

        it 'redirects to the created country' do
          post :create, params: { country: @attrs }
          expect(response).to redirect_to(assigns(:country))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved country as @country' do
          post :create, params: { country: @invalid_attrs }
          assigns(:country).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { country: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created country as @country' do
          post :create, params: { country: @attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved country as @country' do
          post :create, params: { country: @invalid_attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created country as @country' do
          post :create, params: { country: @attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved country as @country' do
          post :create, params: { country: @invalid_attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created country as @country' do
          post :create, params: { country: @attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved country as @country' do
          post :create, params: { country: @invalid_attrs }
          assigns(:country).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { country: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @country = FactoryBot.create(:country)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested country' do
          put :update, params: { id: @country.id, country: @attrs }
        end

        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @attrs }
          assigns(:country).should eq(@country)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @country.id, country: @attrs, move: 'lower' }
          expect(response).to redirect_to(countries_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested country' do
          put :update, params: { id: @country.id, country: @attrs }
        end

        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @attrs }
          assigns(:country).should eq(@country)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @country.id, country: @attrs, move: 'lower' }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested country' do
          put :update, params: { id: @country.id, country: @attrs }
        end

        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @attrs }
          assigns(:country).should eq(@country)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @country.id, country: @attrs, move: 'lower' }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested country' do
          put :update, params: { id: @country.id, country: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @country.id, country: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested country as @country' do
          put :update, params: { id: @country.id, country: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @country = FactoryBot.create(:country)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested country' do
        delete :destroy, params: { id: @country.id }
      end

      it 'redirects to the countries list' do
        delete :destroy, params: { id: @country.id }
        expect(response).to redirect_to(countries_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested country' do
        delete :destroy, params: { id: @country.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @country.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested country' do
        delete :destroy, params: { id: @country.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @country.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested country' do
        delete :destroy, params: { id: @country.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @country.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
