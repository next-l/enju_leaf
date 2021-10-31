require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe DonatesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:donate)
  end

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all donates as @donates' do
        get :index
        expect(assigns(:donates)).to eq(Donate.order('id DESC').page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all donates as @donates' do
        get :index
        expect(assigns(:donates)).to eq(Donate.order('id DESC').page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all donates as @donates' do
        get :index
        expect(assigns(:donates)).to be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all donates as @donates' do
        get :index
        expect(assigns(:donates)).to be_nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :show, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :show, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :show, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :show, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested donate as @donate' do
        get :new
        expect(assigns(:donate)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested donate as @donate' do
        get :new
        expect(assigns(:donate)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested donate as @donate' do
        get :new
        expect(assigns(:donate)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested donate as @donate' do
        get :new
        expect(assigns(:donate)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :edit, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :edit, params: { id: donate.id }
        expect(assigns(:donate)).to eq(donate)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :edit, params: { id: donate.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested donate as @donate' do
        donate = FactoryBot.create(:donate)
        get :edit, params: { id: donate.id }
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
        it 'assigns a newly created donate as @donate' do
          post :create, params: { donate: @attrs }
          expect(assigns(:donate)).to be_valid
        end

        it 'redirects to the created donate' do
          post :create, params: { donate: @attrs }
          expect(response).to redirect_to(donate_url(assigns(:donate)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved donate as @donate' do
          post :create, params: { donate: @invalid_attrs }
          expect(assigns(:donate)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { donate: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created donate as @donate' do
          post :create, params: { donate: @attrs }
          expect(assigns(:donate)).to be_valid
        end

        it 'redirects to the created donate' do
          post :create, params: { donate: @attrs }
          expect(response).to redirect_to(donate_url(assigns(:donate)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved donate as @donate' do
          post :create, params: { donate: @invalid_attrs }
          expect(assigns(:donate)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { donate: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created donate as @donate' do
          post :create, params: { donate: @attrs }
          expect(assigns(:donate)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { donate: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved donate as @donate' do
          post :create, params: { donate: @invalid_attrs }
          expect(assigns(:donate)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { donate: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created donate as @donate' do
          post :create, params: { donate: @attrs }
          expect(assigns(:donate)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { donate: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved donate as @donate' do
          post :create, params: { donate: @invalid_attrs }
          expect(assigns(:donate)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { donate: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @donate = FactoryBot.create(:donate)
      @attrs = valid_attributes
      @invalid_attrs = { item_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
        end

        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
          expect(assigns(:donate)).to eq(@donate)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
        end

        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
          expect(assigns(:donate)).to eq(@donate)
          expect(response).to redirect_to(@donate)
        end
      end

      describe 'with invalid params' do
        it 'assigns the donate as @donate' do
          put :update, params: { id: @donate, donate: @invalid_attrs }
          expect(assigns(:donate)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @donate, donate: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
        end

        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
          expect(assigns(:donate)).to eq(@donate)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested donate' do
          put :update, params: { id: @donate.id, donate: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @donate.id, donate: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested donate as @donate' do
          put :update, params: { id: @donate.id, donate: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @donate = FactoryBot.create(:donate)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested donate' do
        delete :destroy, params: { id: @donate.id }
      end

      it 'redirects to the donates list' do
        delete :destroy, params: { id: @donate.id }
        expect(response).to redirect_to(donates_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested donate' do
        delete :destroy, params: { id: @donate.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @donate.id }
        expect(response).to redirect_to(donates_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested donate' do
        delete :destroy, params: { id: @donate.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @donate.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested donate' do
        delete :destroy, params: { id: @donate.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @donate.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
