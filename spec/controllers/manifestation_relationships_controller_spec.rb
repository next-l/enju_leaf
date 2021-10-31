require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ManifestationRelationshipsController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    @attrs = FactoryBot.attributes_for(:manifestation_relationship)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:manifestation_relationship)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all manifestation_relationships as @manifestation_relationships' do
        get :index
        expect(assigns(:manifestation_relationships)).to eq(ManifestationRelationship.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all manifestation_relationships as @manifestation_relationships' do
        get :index
        expect(assigns(:manifestation_relationships)).to eq(ManifestationRelationship.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all manifestation_relationships as @manifestation_relationships' do
        get :index
        expect(assigns(:manifestation_relationships)).to eq(ManifestationRelationship.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all manifestation_relationships as @manifestation_relationships' do
        get :index
        expect(assigns(:manifestation_relationships)).to eq(ManifestationRelationship.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :show, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :show, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :show, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :show, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        get :new
        expect(assigns(:manifestation_relationship)).to be_nil
        expect(response).to redirect_to manifestations_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested manifestation_relationship as @manifestation_relationship' do
        get :new
        expect(assigns(:manifestation_relationship)).to be_nil
        expect(response).to redirect_to manifestations_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested manifestation_relationship as @manifestation_relationship' do
        get :new
        expect(assigns(:manifestation_relationship)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_relationship as @manifestation_relationship' do
        get :new
        expect(assigns(:manifestation_relationship)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :edit, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :edit, params: { id: manifestation_relationship.id }
        expect(assigns(:manifestation_relationship)).to eq(manifestation_relationship)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :edit, params: { id: manifestation_relationship.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested manifestation_relationship as @manifestation_relationship' do
        manifestation_relationship = FactoryBot.create(:manifestation_relationship)
        get :edit, params: { id: manifestation_relationship.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { parent_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to be_valid
        end

        it 'redirects to the created manifestation' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(response).to redirect_to(assigns(:manifestation_relationship))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(assigns(:manifestation_relationship)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to be_valid
        end

        it 'redirects to the created manifestation' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(response).to redirect_to(assigns(:manifestation_relationship))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(assigns(:manifestation_relationship)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(assigns(:manifestation_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_relationship: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved manifestation_relationship as @manifestation_relationship' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(assigns(:manifestation_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { manifestation_relationship: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @manifestation_relationship = FactoryBot.create(:manifestation_relationship)
      @attrs = valid_attributes
      @invalid_attrs = { parent_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
        end

        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to eq(@manifestation_relationship)
          expect(response).to redirect_to(@manifestation_relationship)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs, move: 'lower', manifestation_id: @manifestation_relationship.parent.id }
          expect(response).to redirect_to(manifestation_relationships_url(manifestation_id: @manifestation_relationship.parent_id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
        end

        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to eq(@manifestation_relationship)
          expect(response).to redirect_to(@manifestation_relationship)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
        end

        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
          expect(assigns(:manifestation_relationship)).to eq(@manifestation_relationship)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested manifestation_relationship as @manifestation_relationship' do
          put :update, params: { id: @manifestation_relationship.id, manifestation_relationship: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @manifestation_relationship = FactoryBot.create(:manifestation_relationship)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested manifestation_relationship' do
        delete :destroy, params: { id: @manifestation_relationship.id }
      end

      it 'redirects to the manifestation_relationships list' do
        delete :destroy, params: { id: @manifestation_relationship.id }
        expect(response).to redirect_to(manifestation_relationships_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested manifestation_relationship' do
        delete :destroy, params: { id: @manifestation_relationship.id }
      end

      it 'redirects to the manifestation_relationships list' do
        delete :destroy, params: { id: @manifestation_relationship.id }
        expect(response).to redirect_to(manifestation_relationships_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested manifestation_relationship' do
        delete :destroy, params: { id: @manifestation_relationship.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_relationship.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested manifestation_relationship' do
        delete :destroy, params: { id: @manifestation_relationship.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @manifestation_relationship.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
