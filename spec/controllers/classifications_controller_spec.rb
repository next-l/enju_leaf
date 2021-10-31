require 'rails_helper'

describe ClassificationsController do
  fixtures :all

  def valid_attributes
    FactoryBot.attributes_for(:classification)
  end

  describe 'GET index', solr: true do
    before do
      Classification.reindex
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns all classifications as @classifications' do
        get :index
        expect(assigns(:classifications)).not_to be_empty
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns all classifications as @classifications' do
        get :index
        expect(assigns(:classifications)).not_to be_empty
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns all classifications as @classifications' do
        get :index
        expect(assigns(:classifications)).not_to be_empty
      end
    end

    describe 'When not logged in' do
      it 'assigns all classifications as @classifications' do
        get :index
        expect(assigns(:classifications)).not_to be_empty
      end

      it 'should get index with query' do
        get :index, params: { query: '500' }
        response.should be_successful
        expect(assigns(:classifications)).not_to be_empty
      end
    end
  end

  describe 'GET show' do
    before(:each) do
      @classification = FactoryBot.create(:classification)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification as @classification' do
        get :show, params: { id: @classification.id }
        expect(assigns(:classification)).to eq(@classification)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested classification as @classification' do
        get :show, params: { id: @classification.id }
        expect(assigns(:classification)).to eq(@classification)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested classification as @classification' do
        get :show, params: { id: @classification.id }
        expect(assigns(:classification)).to eq(@classification)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested classification as @classification' do
        get :show, params: { id: @classification.id }
        expect(assigns(:classification)).to eq(@classification)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification as @classification' do
        get :new
        expect(assigns(:classification)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested classification as @classification' do
        get :new
        expect(assigns(:classification)).to be_nil
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'should assign the requested classification as @classification' do
        get :new
        expect(assigns(:classification)).to be_nil
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested classification as @classification' do
        get :new
        expect(assigns(:classification)).to be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification as @classification' do
        classification = FactoryBot.create(:classification)
        get :edit, params: { id: classification.id }
        expect(assigns(:classification)).to eq(classification)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested classification as @classification' do
        classification = FactoryBot.create(:classification)
        get :edit, params: { id: classification.id }
        expect(assigns(:classification)).to eq(classification)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested classification as @classification' do
        classification = FactoryBot.create(:classification)
        get :edit, params: { id: classification.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested classification as @classification' do
        classification = FactoryBot.create(:classification)
        get :edit, params: { id: classification.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { category: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'assigns a newly created classification as @classification' do
          post :create, params: { classification: @attrs }
          expect(assigns(:classification)).to be_valid
        end

        it 'redirects to the created classification' do
          post :create, params: { classification: @attrs }
          response.should redirect_to(classification_url(assigns(:classification)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification as @classification' do
          post :create, params: { classification: @invalid_attrs }
          expect(assigns(:classification)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { classification: @invalid_attrs }
          response.should render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'assigns a newly created classification as @classification' do
          post :create, params: { classification: @attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification as @classification' do
          post :create, params: { classification: @invalid_attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'assigns a newly created classification as @classification' do
          post :create, params: { classification: @attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification as @classification' do
          post :create, params: { classification: @invalid_attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created classification as @classification' do
          post :create, params: { classification: @attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification as @classification' do
          post :create, params: { classification: @invalid_attrs }
          expect(assigns(:classification)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @classification = FactoryBot.create(:classification)
      @attrs = valid_attributes
      @invalid_attrs = { category: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'updates the requested classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
        end

        it 'assigns the requested classification as @classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
          expect(assigns(:classification)).to eq(@classification)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification as @classification' do
          put :update, params: { id: @classification.id, classification: @invalid_attrs }
          response.should render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'updates the requested classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @classification.id, classification: @attrs }
          expect(assigns(:classification)).to eq(@classification)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'should be forbidden' do
          put :update, params: { id: @classification, classification: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'updates the requested classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
        end

        it 'assigns the requested classification as @classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
          expect(assigns(:classification)).to eq(@classification)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification as @classification' do
          put :update, params: { id: @classification.id, classification: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested classification' do
          put :update, params: { id: @classification.id, classification: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @classification.id, classification: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification as @classification' do
          put :update, params: { id: @classification.id, classification: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @classification = FactoryBot.create(:classification)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'destroys the requested classification' do
        delete :destroy, params: { id: @classification.id }
      end

      it 'redirects to the classifications list' do
        delete :destroy, params: { id: @classification.id }
        response.should redirect_to(classifications_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'destroys the requested classification' do
        delete :destroy, params: { id: @classification.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification.id }
        response.should be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'destroys the requested classification' do
        delete :destroy, params: { id: @classification.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested classification' do
        delete :destroy, params: { id: @classification.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
