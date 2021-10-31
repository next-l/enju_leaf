require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe RealizesController do
  fixtures :all
  disconnect_sunspot

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all realizes as @realizes' do
        get :index
        expect(assigns(:realizes)).to eq(Realize.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all realizes as @realizes' do
        get :index
        expect(assigns(:realizes)).to eq(Realize.page(1))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all realizes as @realizes' do
        get :index
        expect(assigns(:realizes)).to eq(Realize.page(1))
      end
    end

    describe 'When not logged in' do
      it 'assigns all realizes as @realizes' do
        get :index
        expect(assigns(:realizes)).to eq(Realize.page(1))
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :show, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :show, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :show, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :show, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested realize as @realize' do
        get :new
        expect(assigns(:realize)).not_to be_valid
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested realize as @realize' do
        get :new
        expect(assigns(:realize)).not_to be_valid
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested realize as @realize' do
        get :new
        expect(assigns(:realize)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested realize as @realize' do
        get :new
        expect(assigns(:realize)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :edit, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :edit, params: { id: realize.id }
        expect(assigns(:realize)).to eq(realize)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :edit, params: { id: realize.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested realize as @realize' do
        realize = FactoryBot.create(:realize)
        get :edit, params: { id: realize.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:realize)
      @invalid_attrs = { expression_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'assigns a newly created realize as @realize' do
          post :create, params: { realize: @attrs }
          expect(assigns(:realize)).to be_valid
        end

        it 'redirects to the created realize' do
          post :create, params: { realize: @attrs }
          expect(response).to redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved realize as @realize' do
          post :create, params: { realize: @invalid_attrs }
          expect(assigns(:realize)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { realize: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created realize as @realize' do
          post :create, params: { realize: @attrs }
          expect(assigns(:realize)).to be_valid
        end

        it 'redirects to the created realize' do
          post :create, params: { realize: @attrs }
          expect(response).to redirect_to(realize_url(assigns(:realize)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved realize as @realize' do
          post :create, params: { realize: @invalid_attrs }
          expect(assigns(:realize)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { realize: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created realize as @realize' do
          post :create, params: { realize: @attrs }
          expect(assigns(:realize)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { realize: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved realize as @realize' do
          post :create, params: { realize: @invalid_attrs }
          expect(assigns(:realize)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { realize: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created realize as @realize' do
          post :create, params: { realize: @attrs }
          expect(assigns(:realize)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { realize: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved realize as @realize' do
          post :create, params: { realize: @invalid_attrs }
          expect(assigns(:realize)).to be_nil
        end

        it 'should redirect to new_user_session_url' do
          post :create, params: { realize: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @realize = realizes(:realize_00001)
      @attrs = FactoryBot.attributes_for(:realize)
      @invalid_attrs = { expression_id: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
        end

        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
          expect(assigns(:realize)).to eq(@realize)
          expect(response).to redirect_to(@realize)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
        end

        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
          expect(assigns(:realize)).to eq(@realize)
          expect(response).to redirect_to(@realize)
        end

        it 'moves its position when specified' do
          position = @realize.position
          put :update, params: { id: @realize.id, expression_id: @realize.expression.id, move: 'lower' }
          expect(response).to redirect_to realizes_url(expression_id: @realize.expression_id)
          assigns(:realize).reload.position.should eq position + 1
        end
      end

      describe 'with invalid params' do
        it 'assigns the realize as @realize' do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
          expect(assigns(:realize)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
        end

        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
          expect(assigns(:realize)).to eq(@realize)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested realize' do
          put :update, params: { id: @realize.id, realize: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @realize.id, realize: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested realize as @realize' do
          put :update, params: { id: @realize.id, realize: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @realize = FactoryBot.create(:realize)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested realize' do
        delete :destroy, params: { id: @realize.id }
      end

      it 'redirects to the realizes list' do
        delete :destroy, params: { id: @realize.id }
        expect(response).to redirect_to(realizes_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested realize' do
        delete :destroy, params: { id: @realize.id }
      end

      it 'redirects to the realizes list' do
        delete :destroy, params: { id: @realize.id }
        expect(response).to redirect_to(realizes_url)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested realize' do
        delete :destroy, params: { id: @realize.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @realize.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested realize' do
        delete :destroy, params: { id: @realize.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @realize.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
