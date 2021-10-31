require 'rails_helper'

describe AgentMergesController do
  fixtures :all

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:agent_merge)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns all agent_merges as @agent_merges' do
        get :index
        assigns(:agent_merges).should eq(AgentMerge.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns all agent_merges as @agent_merges' do
        get :index
        assigns(:agent_merges).should eq(AgentMerge.page(1))
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'should be forbidden' do
        get :index
        assigns(:agent_merges).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should be forbidden' do
        get :index
        assigns(:agent_merges).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :show, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :show, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :show, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :show, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested agent_merge as @agent_merge' do
        get :new
        assigns(:agent_merge).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested agent_merge as @agent_merge' do
        get :new
        assigns(:agent_merge).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'should not assign the requested agent_merge as @agent_merge' do
        get :new
        assigns(:agent_merge).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested agent_merge as @agent_merge' do
        get :new
        assigns(:agent_merge).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :edit, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :edit, params: { id: agent_merge.id }
        assigns(:agent_merge).should eq(agent_merge)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :edit, params: { id: agent_merge.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested agent_merge as @agent_merge' do
        agent_merge = FactoryBot.create(:agent_merge)
        get :edit, params: { id: agent_merge.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:agent_merge)
      @invalid_attrs = { agent_id: 'invalid', agent_merge_list_id: 'invalid' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'assigns a newly created agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @attrs }
          assigns(:agent_merge).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { agent_merge: @attrs }
          response.should redirect_to(assigns(:agent_merge))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @invalid_attrs }
          assigns(:agent_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { agent_merge: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'assigns a newly created agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @attrs }
          assigns(:agent_merge).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { agent_merge: @attrs }
          response.should redirect_to(assigns(:agent_merge))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @invalid_attrs }
          assigns(:agent_merge).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { agent_merge: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'assigns a newly created agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @attrs }
          assigns(:agent_merge).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_merge: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @invalid_attrs }
          assigns(:agent_merge).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_merge: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @attrs }
          assigns(:agent_merge).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_merge: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved agent_merge as @agent_merge' do
          post :create, params: { agent_merge: @invalid_attrs }
          assigns(:agent_merge).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { agent_merge: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @agent_merge = FactoryBot.create(:agent_merge)
      @attrs = FactoryBot.attributes_for(:agent_merge)
      @invalid_attrs = { agent_merge_list_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'updates the requested agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
        end

        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
          assigns(:agent_merge).should eq(@agent_merge)
          response.should redirect_to(@agent_merge)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'updates the requested agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
        end

        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
          assigns(:agent_merge).should eq(@agent_merge)
          response.should redirect_to(@agent_merge)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'updates the requested agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
        end

        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
          assigns(:agent_merge).should eq(@agent_merge)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @agent_merge.id, agent_merge: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested agent_merge as @agent_merge' do
          put :update, params: { id: @agent_merge.id, agent_merge: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @agent_merge = FactoryBot.create(:agent_merge)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'destroys the requested agent_merge' do
        delete :destroy, params: { id: @agent_merge.id }
      end

      it 'redirects to the agent_merges list' do
        delete :destroy, params: { id: @agent_merge.id }
        response.should redirect_to(agent_merges_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'destroys the requested agent_merge' do
        delete :destroy, params: { id: @agent_merge.id }
      end

      it 'redirects to the agent_merges list' do
        delete :destroy, params: { id: @agent_merge.id }
        response.should redirect_to(agent_merges_url)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'destroys the requested agent_merge' do
        delete :destroy, params: { id: @agent_merge.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @agent_merge.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested agent_merge' do
        delete :destroy, params: { id: @agent_merge.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @agent_merge.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
