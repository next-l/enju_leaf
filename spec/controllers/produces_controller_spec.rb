require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ProducesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    FactoryBot.attributes_for(:produce)
  end

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all produces as @produces' do
        get :index
        expect(assigns(:produces)).to eq(Produce.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all produces as @produces' do
        get :index
        expect(assigns(:produces)).to eq(Produce.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all produces as @produces' do
        get :index
        expect(assigns(:produces)).to eq(Produce.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all produces as @produces' do
        get :index
        expect(assigns(:produces)).to eq(Produce.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :show, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :show, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :show, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :show, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested produce as @produce' do
        get :new
        expect(assigns(:produce)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested produce as @produce' do
        get :new
        expect(assigns(:produce)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested produce as @produce' do
        get :new
        expect(assigns(:produce)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested produce as @produce' do
        get :new
        expect(assigns(:produce)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :edit, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :edit, params: { id: produce.id }
        expect(assigns(:produce)).to eq(produce)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :edit, params: { id: produce.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested produce as @produce' do
        produce = FactoryBot.create(:produce)
        get :edit, params: { id: produce.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = { manifestation_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created produce as @produce' do
          post :create, params: { produce: @attrs }
          expect(assigns(:produce)).to be_valid
        end

        it 'redirects to the created produce' do
          post :create, params: { produce: @attrs }
          expect(response).to redirect_to(produce_url(assigns(:produce)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved produce as @produce' do
          post :create, params: { produce: @invalid_attrs }
          expect(assigns(:produce)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { produce: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created produce as @produce' do
          post :create, params: { produce: @attrs }
          expect(assigns(:produce)).to be_valid
        end

        it 'redirects to the created produce' do
          post :create, params: { produce: @attrs }
          expect(response).to redirect_to(produce_url(assigns(:produce)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved produce as @produce' do
          post :create, params: { produce: @invalid_attrs }
          expect(assigns(:produce)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { produce: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created produce as @produce' do
          post :create, params: { produce: @attrs }
          expect(assigns(:produce)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { produce: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved produce as @produce' do
          post :create, params: { produce: @invalid_attrs }
          expect(assigns(:produce)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { produce: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created produce as @produce' do
          post :create, params: { produce: @attrs }
          expect(assigns(:produce)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { produce: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved produce as @produce' do
          post :create, params: { produce: @invalid_attrs }
          expect(assigns(:produce)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { produce: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @produce = produces(:produce_00001)
      @attrs = valid_attributes
      @invalid_attrs = { manifestation_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
        end

        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
          expect(assigns(:produce)).to eq(@produce)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
        end

        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
          expect(assigns(:produce)).to eq(@produce)
          expect(response).to redirect_to(@produce)
        end

        it 'moves its position when specified' do
          position = @produce.position
          put :update, params: { id: @produce.id, manifestation_id: @produce.manifestation.id, move: 'lower' }
          expect(response).to redirect_to produces_url(manifestation_id: @produce.manifestation_id)
          assigns(:produce).reload.position.should eq position + 1
        end
      end

      describe 'with invalid params' do
        it 'assigns the produce as @produce' do
          put :update, params: { id: @produce, produce: @invalid_attrs }
          expect(assigns(:produce)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @produce, produce: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
        end

        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
          expect(assigns(:produce)).to eq(@produce)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested produce' do
          put :update, params: { id: @produce.id, produce: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @produce.id, produce: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested produce as @produce' do
          put :update, params: { id: @produce.id, produce: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @produce = FactoryBot.create(:produce)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested produce' do
        delete :destroy, params: { id: @produce.id }
      end

      it 'redirects to the produces list' do
        delete :destroy, params: { id: @produce.id }
        expect(response).to redirect_to(produces_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested produce' do
        delete :destroy, params: { id: @produce.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @produce.id }
        expect(response).to redirect_to(produces_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested produce' do
        delete :destroy, params: { id: @produce.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @produce.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested produce' do
        delete :destroy, params: { id: @produce.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @produce.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
