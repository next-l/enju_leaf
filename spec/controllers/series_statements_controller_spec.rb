require 'rails_helper'

describe SeriesStatementsController do
  fixtures :users

  def valid_attributes
    FactoryBot.attributes_for(:series_statement)
  end

  describe 'GET index', solr: true do
    before do
      SeriesStatement.reindex
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all series_statements as @series_statements' do
        get :index
        expect(assigns(:series_statements)).not_to be_nil
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all series_statements as @series_statements' do
        get :index
        expect(assigns(:series_statements)).not_to be_nil
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all series_statements as @series_statements' do
        get :index
        expect(assigns(:series_statements)).not_to be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all series_statements as @series_statements' do
        get :index
        expect(assigns(:series_statements)).not_to be_nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :show, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :show, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :show, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
        expect(response).to be_successful
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :show, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
        expect(response).to be_successful
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested series_statement as @series_statement' do
        get :new
        expect(assigns(:series_statement)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested series_statement as @series_statement' do
        get :new
        expect(assigns(:series_statement)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested series_statement as @series_statement' do
        get :new
        expect(assigns(:series_statement)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested series_statement as @series_statement' do
        get :new
        expect(assigns(:series_statement)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :edit, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :edit, params: { id: series_statement.id }
        expect(assigns(:series_statement)).to eq(series_statement)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :edit, params: { id: series_statement.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested series_statement as @series_statement' do
        series_statement = FactoryBot.create(:series_statement)
        get :edit, params: { id: series_statement.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { original_title: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created series_statement as @series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(assigns(:series_statement)).to be_valid
        end

        it 'redirects to the created series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(response).to redirect_to(series_statement_url(assigns(:series_statement)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved series_statement as @series_statement' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(assigns(:series_statement)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { series_statement: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created series_statement as @series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(assigns(:series_statement)).to be_valid
        end

        it 'redirects to the created series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(response).to redirect_to(series_statement_url(assigns(:series_statement)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved series_statement as @series_statement' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(assigns(:series_statement)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { series_statement: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created series_statement as @series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(assigns(:series_statement)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { series_statement: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved series_statement as @series_statement' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(assigns(:series_statement)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created series_statement as @series_statement' do
          post :create, params: { series_statement: @attrs }
          expect(assigns(:series_statement)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { series_statement: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved series_statement as @series_statement' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(assigns(:series_statement)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { series_statement: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @series_statement = FactoryBot.create(:series_statement)
      @attrs = valid_attributes
      @invalid_attrs = { original_title: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
        end

        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
          expect(assigns(:series_statement)).to eq(@series_statement)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @series_statement.id, move: 'lower' }
          expect(response).to redirect_to(series_statements_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
        end

        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
          expect(assigns(:series_statement)).to eq(@series_statement)
          expect(response).to redirect_to(@series_statement)
        end
      end

      describe 'with invalid params' do
        it 'assigns the series_statement as @series_statement' do
          put :update, params: { id: @series_statement, series_statement: @invalid_attrs }
          expect(assigns(:series_statement)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @series_statement, series_statement: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
        end

        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
          expect(assigns(:series_statement)).to eq(@series_statement)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @series_statement.id, series_statement: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested series_statement as @series_statement' do
          put :update, params: { id: @series_statement.id, series_statement: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @series_statement = FactoryBot.create(:series_statement)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested series_statement' do
        delete :destroy, params: { id: @series_statement.id }
      end

      it 'redirects to the series_statements list' do
        delete :destroy, params: { id: @series_statement.id }
        expect(response).to redirect_to(series_statements_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested series_statement' do
        delete :destroy, params: { id: @series_statement.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @series_statement.id }
        expect(response).to redirect_to(series_statements_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested series_statement' do
        delete :destroy, params: { id: @series_statement.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @series_statement.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested series_statement' do
        delete :destroy, params: { id: @series_statement.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @series_statement.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
