require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ManifestationCustomPropertiesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    @attrs = FactoryBot.attributes_for(:manifestation_custom_property)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:manifestation_custom_property)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all manifestation_custom_properties as @manifestation_custom_properties' do
        get :index
        expect(assigns(:manifestation_custom_properties)).to eq(ManifestationCustomProperty.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all manifestation_custom_properties as @manifestation_custom_properties' do
        get :index
        expect(assigns(:manifestation_custom_properties)).to eq(ManifestationCustomProperty.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all manifestation_custom_properties as @manifestation_custom_properties' do
        get :index
        expect(assigns(:manifestation_custom_properties)).to eq nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all manifestation_custom_properties as @manifestation_custom_properties' do
        get :index
        expect(assigns(:manifestation_custom_properties)).to eq nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :show, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :show, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :show, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :show, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        get :new
        expect(assigns(:manifestation_custom_property)).to be_a_new(ManifestationCustomProperty)
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested manifestation_custom_property as @manifestation_custom_property' do
        get :new
        expect(assigns(:manifestation_custom_property)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested manifestation_custom_property as @manifestation_custom_property' do
        get :new
        expect(assigns(:manifestation_custom_property)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_custom_property as @manifestation_custom_property' do
        get :new
        expect(assigns(:manifestation_custom_property)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :edit, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :edit, params: { id: manifestation_custom_property.id }
        expect(assigns(:manifestation_custom_property)).to eq(manifestation_custom_property)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :edit, params: { id: manifestation_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_custom_property as @manifestation_custom_property' do
        manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
        get :edit, params: { id: manifestation_custom_property.id }
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
        it 'assigns a newly created manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to be_valid
        end

        it 'redirects to the created manifestation' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(response).to redirect_to(assigns(:manifestation_custom_property))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(assigns(:manifestation_custom_property)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it 'redirects to the created manifestation' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_custom_property: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_custom_property as @manifestation_custom_property' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(assigns(:manifestation_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_custom_property: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
        end

        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to eq(@manifestation_custom_property)
          expect(response).to redirect_to(@manifestation_custom_property)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end

      it 'moves its position when specified' do
        manifestation_custom_property = ManifestationCustomProperty.create! valid_attributes
        position = manifestation_custom_property.position
        put :update, params: { id: manifestation_custom_property.id, move: 'higher' }
        expect(response).to redirect_to manifestation_custom_properties_url
        assigns(:manifestation_custom_property).reload.position.should eq position - 1
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
        end

        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to eq @manifestation_custom_property
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
        end

        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
          expect(assigns(:manifestation_custom_property)).to eq(@manifestation_custom_property)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_custom_property as @manifestation_custom_property' do
          put :update, params: { id: @manifestation_custom_property.id, manifestation_custom_property: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @manifestation_custom_property = FactoryBot.create(:manifestation_custom_property)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested manifestation_custom_property' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
      end

      it 'redirects to the manifestation_custom_properties list' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
        expect(response).to redirect_to(manifestation_custom_properties_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested manifestation_custom_property' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested manifestation_custom_property' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested manifestation_custom_property' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_custom_property.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
