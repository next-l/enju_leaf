require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe AgentRelationshipsController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    @attrs = FactoryBot.attributes_for(:agent_relationship)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:agent_relationship)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all agent_relationships as @agent_relationships' do
        get :index
        expect(assigns(:agent_relationships)).to eq(AgentRelationship.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all agent_relationships as @agent_relationships' do
        get :index
        expect(assigns(:agent_relationships)).to eq(AgentRelationship.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all agent_relationships as @agent_relationships' do
        get :index
        expect(assigns(:agent_relationships)).to eq(AgentRelationship.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all agent_relationships as @agent_relationships' do
        get :index
        expect(assigns(:agent_relationships)).to eq(AgentRelationship.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :show, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :show, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :show, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :show, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested agent_relationship as @agent_relationship' do
        get :new
        expect(assigns(:agent_relationship)).to be_nil
        expect(response).to redirect_to agents_url
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested agent_relationship as @agent_relationship' do
        get :new
        expect(assigns(:agent_relationship)).to be_nil
        expect(response).to redirect_to agents_url
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested agent_relationship as @agent_relationship' do
        get :new
        expect(assigns(:agent_relationship)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested agent_relationship as @agent_relationship' do
        get :new
        expect(assigns(:agent_relationship)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :edit, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :edit, params: { id: agent_relationship.id }
        expect(assigns(:agent_relationship)).to eq(agent_relationship)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :edit, params: { id: agent_relationship.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested agent_relationship as @agent_relationship' do
        agent_relationship = FactoryBot.create(:agent_relationship)
        get :edit, params: { id: agent_relationship.id }
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
        it 'assigns a newly created agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { agent_relationship: @attrs }
          expect(response).to redirect_to(assigns(:agent_relationship))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(assigns(:agent_relationship)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { agent_relationship: @attrs }
          expect(response).to redirect_to(assigns(:agent_relationship))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(assigns(:agent_relationship)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_relationship: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(assigns(:agent_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_relationship: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_relationship as @agent_relationship' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(assigns(:agent_relationship)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_relationship: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @agent_relationship = FactoryBot.create(:agent_relationship)
      @attrs = valid_attributes
      @invalid_attrs = { parent_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
        end

        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to eq(@agent_relationship)
          expect(response).to redirect_to(@agent_relationship)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs, move: 'lower', agent_id: @agent_relationship.parent.id }
          expect(response).to redirect_to(agent_relationships_url(agent_id: @agent_relationship.parent_id))
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
        end

        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to eq(@agent_relationship)
          expect(response).to redirect_to(@agent_relationship)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
        end

        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
          expect(assigns(:agent_relationship)).to eq(@agent_relationship)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_relationship as @agent_relationship' do
          put :update, params: { id: @agent_relationship.id, agent_relationship: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @agent_relationship = FactoryBot.create(:agent_relationship)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested agent_relationship' do
        delete :destroy, params: { id: @agent_relationship.id }
      end

      it 'redirects to the agent_relationships list' do
        delete :destroy, params: { id: @agent_relationship.id }
        expect(response).to redirect_to(agent_relationships_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested agent_relationship' do
        delete :destroy, params: { id: @agent_relationship.id }
      end

      it 'redirects to the agent_relationships list' do
        delete :destroy, params: { id: @agent_relationship.id }
        expect(response).to redirect_to(agent_relationships_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested agent_relationship' do
        delete :destroy, params: { id: @agent_relationship.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @agent_relationship.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested agent_relationship' do
        delete :destroy, params: { id: @agent_relationship.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @agent_relationship.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
