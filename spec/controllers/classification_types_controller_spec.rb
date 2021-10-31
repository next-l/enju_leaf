require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ClassificationTypesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:classification_type)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:classification_type)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns all classification_types as @classification_types' do
        get :index
        expect(assigns(:classification_types)).to eq(ClassificationType.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns all classification_types as @classification_types' do
        get :index
        expect(assigns(:classification_types)).to eq(ClassificationType.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns all classification_types as @classification_types' do
        get :index
        expect(assigns(:classification_types)).to eq(ClassificationType.order(:position))
      end
    end

    describe 'When not logged in' do
      it 'assigns all classification_types as @classification_types' do
        get :index
        expect(assigns(:classification_types)).to eq(ClassificationType.order(:position))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :show, params: { id: classification_type.id }
        expect(assigns(:classification_type)).to eq(classification_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :show, params: { id: classification_type.id }
        expect(assigns(:classification_type)).to eq(classification_type)
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :show, params: { id: classification_type.id }
        expect(assigns(:classification_type)).to eq(classification_type)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :show, params: { id: classification_type.id }
        expect(assigns(:classification_type)).to eq(classification_type)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification_type as @classification_type' do
        get :new
        expect(assigns(:classification_type)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'should not assign the requested classification_type as @classification_type' do
        get :new
        expect(assigns(:classification_type)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'should not assign the requested classification_type as @classification_type' do
        get :new
        expect(assigns(:classification_type)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested classification_type as @classification_type' do
        get :new
        expect(assigns(:classification_type)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_admin

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :edit, params: { id: classification_type.id }
        expect(assigns(:classification_type)).to eq(classification_type)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :edit, params: { id: classification_type.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'assigns the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :edit, params: { id: classification_type.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested classification_type as @classification_type' do
        classification_type = FactoryBot.create(:classification_type)
        get :edit, params: { id: classification_type.id }
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
      login_admin

      describe 'with valid params' do
        it 'assigns a newly created classification_type as @classification_type' do
          post :create, params: { classification_type: @attrs }
          expect(assigns(:classification_type)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { classification_type: @attrs }
          expect(response).to redirect_to(assigns(:classification_type))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification_type as @classification_type' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(assigns(:classification_type)).not_to be_valid
        end

        it 'should be successful' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(response).to be_successful
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'assigns a newly created classification_type as @classification_type' do
          post :create, params: { classification_type: @attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification_type as @classification_type' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'assigns a newly created classification_type as @classification_type' do
          post :create, params: { classification_type: @attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification_type as @classification_type' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created classification_type as @classification_type' do
          post :create, params: { classification_type: @attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved classification_type as @classification_type' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(assigns(:classification_type)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { classification_type: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @classification_type = FactoryBot.create(:classification_type)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_admin

      describe 'with valid params' do
        it 'updates the requested classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
        end

        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
          expect(assigns(:classification_type)).to eq(@classification_type)
        end

        it 'moves its position when specified' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs, move: 'lower' }
          expect(response).to redirect_to(classification_types_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      describe 'with valid params' do
        it 'updates the requested classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
        end

        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
          expect(assigns(:classification_type)).to eq(@classification_type)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_user

      describe 'with valid params' do
        it 'updates the requested classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
        end

        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
          expect(assigns(:classification_type)).to eq(@classification_type)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @classification_type.id, classification_type: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested classification_type as @classification_type' do
          put :update, params: { id: @classification_type.id, classification_type: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @classification_type = FactoryBot.create(:classification_type)
    end

    describe 'When logged in as Administrator' do
      login_admin

      it 'destroys the requested classification_type' do
        delete :destroy, params: { id: @classification_type.id }
      end

      it 'redirects to the classification_types list' do
        delete :destroy, params: { id: @classification_type.id }
        expect(response).to redirect_to(classification_types_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_librarian

      it 'destroys the requested classification_type' do
        delete :destroy, params: { id: @classification_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification_type.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_user

      it 'destroys the requested classification_type' do
        delete :destroy, params: { id: @classification_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification_type.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested classification_type' do
        delete :destroy, params: { id: @classification_type.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @classification_type.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
