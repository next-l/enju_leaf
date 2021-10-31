require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe ItemCustomPropertiesController do
  fixtures :all
  disconnect_sunspot

  def valid_attributes
    @attrs = FactoryBot.attributes_for(:item_custom_property)
  end

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:item_custom_property)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns all item_custom_properties as @item_custom_properties' do
        get :index
        expect(assigns(:item_custom_properties)).to eq(ItemCustomProperty.order(:position))
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns all item_custom_properties as @item_custom_properties' do
        get :index
        expect(assigns(:item_custom_properties)).to eq(ItemCustomProperty.order(:position))
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns all item_custom_properties as @item_custom_properties' do
        get :index
        expect(assigns(:item_custom_properties)).to eq nil
      end
    end

    describe 'When not logged in' do
      it 'assigns all item_custom_properties as @item_custom_properties' do
        get :index
        expect(assigns(:item_custom_properties)).to eq nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :show, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :show, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :show, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :show, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item_custom_property as @item_custom_property' do
        get :new
        expect(assigns(:item_custom_property)).to be_a_new(ItemCustomProperty)
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'should not assign the requested item_custom_property as @item_custom_property' do
        get :new
        expect(assigns(:item_custom_property)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'should not assign the requested item_custom_property as @item_custom_property' do
        get :new
        expect(assigns(:item_custom_property)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested item_custom_property as @item_custom_property' do
        get :new
        expect(assigns(:item_custom_property)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :edit, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :edit, params: { id: item_custom_property.id }
        expect(assigns(:item_custom_property)).to eq(item_custom_property)
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'assigns the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :edit, params: { id: item_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested item_custom_property as @item_custom_property' do
        item_custom_property = FactoryBot.create(:item_custom_property)
        get :edit, params: { id: item_custom_property.id }
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
        it 'assigns a newly created item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to be_valid
        end

        it 'redirects to the created item' do
          post :create, params: { item_custom_property: @attrs }
          expect(response).to redirect_to(assigns(:item_custom_property))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(assigns(:item_custom_property)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'assigns a newly created item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it 'redirects to the created item' do
          post :create, params: { item_custom_property: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it "re-renders the 'new' template" do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'assigns a newly created item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item_custom_property: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item_custom_property: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved item_custom_property as @item_custom_property' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(assigns(:item_custom_property)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { item_custom_property: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @item_custom_property = FactoryBot.create(:item_custom_property)
      @attrs = valid_attributes
      @invalid_attrs = { name: '' }
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      describe 'with valid params' do
        it 'updates the requested item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
        end

        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to eq(@item_custom_property)
          expect(response).to redirect_to(@item_custom_property)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end

      it 'moves its position when specified' do
        item_custom_property = ItemCustomProperty.create! valid_attributes
        position = item_custom_property.position
        put :update, params: { id: item_custom_property.id, move: 'higher' }
        expect(response).to redirect_to item_custom_properties_url
        assigns(:item_custom_property).reload.position.should eq position - 1
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      describe 'with valid params' do
        it 'updates the requested item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
        end

        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to eq @item_custom_property
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      describe 'with valid params' do
        it 'updates the requested item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
        end

        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
          expect(assigns(:item_custom_property)).to eq(@item_custom_property)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested item_custom_property as @item_custom_property' do
          put :update, params: { id: @item_custom_property.id, item_custom_property: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @item_custom_property = FactoryBot.create(:item_custom_property)
    end

    describe 'When logged in as Administrator' do
      login_fixture_admin

      it 'destroys the requested item_custom_property' do
        delete :destroy, params: { id: @item_custom_property.id }
      end

      it 'redirects to the item_custom_properties list' do
        delete :destroy, params: { id: @item_custom_property.id }
        expect(response).to redirect_to(item_custom_properties_url)
      end
    end

    describe 'When logged in as Librarian' do
      login_fixture_librarian

      it 'destroys the requested item_custom_property' do
        delete :destroy, params: { id: @item_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @item_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When logged in as User' do
      login_fixture_user

      it 'destroys the requested item_custom_property' do
        delete :destroy, params: { id: @item_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @item_custom_property.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested item_custom_property' do
        delete :destroy, params: { id: @item_custom_property.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @item_custom_property.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
