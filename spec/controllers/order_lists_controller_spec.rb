require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe OrderListsController do
  disconnect_sunspot
  fixtures :all

  describe 'GET index' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns all order_lists as @order_lists' do
        get :index
        expect(assigns(:order_lists)).to eq(OrderList.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns all order_lists as @order_lists' do
        get :index
        expect(assigns(:order_lists)).to eq(OrderList.page(1))
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns empty as @order_lists' do
        get :index
        expect(assigns(:order_lists)).to be_nil
      end
    end

    describe 'When not logged in' do
      it 'assigns empty as @order_lists' do
        get :index
        expect(assigns(:order_lists)).to be_nil
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :show, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :show, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :show, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :show, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order_list as @order_list' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order_list as @order_list' do
        get :new
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'should not assign the requested order_list as @order_list' do
        get :new
        expect(assigns(:order_list)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order_list as @order_list' do
        get :new
        expect(assigns(:order_list)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :edit, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :edit, params: { id: order_list.id }
        expect(assigns(:order_list)).to eq(order_list)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :edit, params: { id: order_list.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order_list as @order_list' do
        order_list = FactoryBot.create(:order_list)
        get :edit, params: { id: order_list.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:order_list)
      @invalid_attrs = { bookstore_id: '' }
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      describe 'with valid params' do
        it 'assigns a newly created order_list as @order_list' do
          post :create, params: { order_list: @attrs }
          expect(assigns(:order_list)).to be_valid
        end

        it 'redirects to the created order_list' do
          post :create, params: { order_list: @attrs }
          expect(response).to redirect_to(order_list_url(assigns(:order_list)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order_list as @order_list' do
          post :create, params: { order_list: @invalid_attrs }
          expect(assigns(:order_list)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order_list: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      describe 'with valid params' do
        it 'assigns a newly created order_list as @order_list' do
          post :create, params: { order_list: @attrs }
          expect(assigns(:order_list)).to be_valid
        end

        it 'redirects to the created order_list' do
          post :create, params: { order_list: @attrs }
          expect(response).to redirect_to(order_list_url(assigns(:order_list)))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order_list as @order_list' do
          post :create, params: { order_list: @invalid_attrs }
          expect(assigns(:order_list)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order_list: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      describe 'with valid params' do
        it 'assigns a newly created order_list as @order_list' do
          post :create, params: { order_list: @attrs }
          expect(assigns(:order_list)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order_list: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order_list as @order_list' do
          post :create, params: { order_list: @invalid_attrs }
          expect(assigns(:order_list)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order_list: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created order_list as @order_list' do
          post :create, params: { order_list: @attrs }
          expect(assigns(:order_list)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order_list: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order_list as @order_list' do
          post :create, params: { order_list: @invalid_attrs }
          expect(assigns(:order_list)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order_list: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @order_list = FactoryBot.create(:order_list)
      @attrs = FactoryBot.attributes_for(:order_list)
      @invalid_attrs = { bookstore_id: '' }
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      describe 'with valid params' do
        it 'updates the requested order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
        end

        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
          expect(assigns(:order_list)).to eq(@order_list)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      describe 'with valid params' do
        it 'updates the requested order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
        end

        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
          expect(assigns(:order_list)).to eq(@order_list)
          expect(response).to redirect_to(@order_list)
        end
      end

      describe 'with invalid params' do
        it 'assigns the order_list as @order_list' do
          put :update, params: { id: @order_list, order_list: @invalid_attrs }
          expect(assigns(:order_list)).not_to be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, params: { id: @order_list, order_list: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      describe 'with valid params' do
        it 'updates the requested order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
        end

        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
          expect(assigns(:order_list)).to eq(@order_list)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested order_list' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @order_list.id, order_list: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order_list as @order_list' do
          put :update, params: { id: @order_list.id, order_list: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @order_list = FactoryBot.create(:order_list)
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'destroys the requested order_list' do
        delete :destroy, params: { id: @order_list.id }
      end

      it 'redirects to the order_lists list' do
        delete :destroy, params: { id: @order_list.id }
        expect(response).to redirect_to(order_lists_url)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'destroys the requested order_list' do
        delete :destroy, params: { id: @order_list.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order_list.id }
        expect(response).to redirect_to(order_lists_url)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'destroys the requested order_list' do
        delete :destroy, params: { id: @order_list.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order_list.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested order_list' do
        delete :destroy, params: { id: @order_list.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order_list.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
