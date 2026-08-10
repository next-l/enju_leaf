require 'rails_helper'
require 'sunspot/rails/spec_helper'

describe OrdersController do
  fixtures :all
  disconnect_sunspot

  describe 'GET index' do
    before(:each) do
      FactoryBot.create(:order)
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns all orders as @orders' do
        get :index
        expect(assigns(:orders)).to eq(Order.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns all orders as @orders' do
        get :index
        expect(assigns(:orders)).to eq(Order.page(1))
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'should be forbidden' do
        get :index
        expect(assigns(:orders)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all orders as @orders' do
        get :index
        expect(assigns(:orders)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET show' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end
  end

  describe 'GET new' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).not_to be_valid
        expect(response).to be_successful
      end

      it 'should redirect to assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).not_to be_valid
        expect(response).to be_successful
      end

      it 'assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).not_to be_valid
        expect(response).to be_successful
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'should not assign the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        expect(assigns(:order)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'GET edit' do
    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        expect(assigns(:order)).to eq(order)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe 'POST create' do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:order)
      @invalid_attrs = { order_list_id: '' }
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      describe 'with valid params' do
        it 'assigns a newly created order as @order' do
          post :create, params: { order: @attrs }
          expect(assigns(:order)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { order: @attrs }
          expect(response).to redirect_to(assigns(:order))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          expect(assigns(:order)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      describe 'with valid params' do
        it 'assigns a newly created order as @order' do
          post :create, params: { order: @attrs }
          expect(assigns(:order)).to be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { order: @attrs }
          expect(response).to redirect_to(assigns(:order))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          expect(assigns(:order)).not_to be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order: @invalid_attrs }
          expect(response).to render_template('new')
        end
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      describe 'with valid params' do
        it 'assigns a newly created order as @order' do
          post :create, params: { order: @attrs }
          expect(assigns(:order)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @attrs }
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          expect(assigns(:order)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created order as @order' do
          post :create, params: { order: @attrs }
          expect(assigns(:order)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          expect(assigns(:order)).to be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'PUT update' do
    before(:each) do
      @order = FactoryBot.create(:order)
      @attrs = FactoryBot.attributes_for(:order)
      @invalid_attrs = { order_list_id: '' }
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      describe 'with valid params' do
        it 'updates the requested order' do
          put :update, params: { id: @order.id, order: @attrs }
        end

        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @attrs }
          expect(assigns(:order)).to eq(@order)
          expect(response).to redirect_to(@order)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      describe 'with valid params' do
        it 'updates the requested order' do
          put :update, params: { id: @order.id, order: @attrs }
        end

        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @attrs }
          expect(assigns(:order)).to eq(@order)
          expect(response).to redirect_to(@order)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      describe 'with valid params' do
        it 'updates the requested order' do
          put :update, params: { id: @order.id, order: @attrs }
        end

        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @attrs }
          expect(assigns(:order)).to eq(@order)
          expect(response).to be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          expect(response).to be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'updates the requested order' do
          put :update, params: { id: @order.id, order: @attrs }
        end

        it 'should be forbidden' do
          put :update, params: { id: @order.id, order: @attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          expect(response).to redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe 'DELETE destroy' do
    before(:each) do
      @order = FactoryBot.create(:order)
    end

    describe 'When logged in as Administrator' do
      before(:each) do
        sign_in FactoryBot.create(:admin)
      end

      it 'destroys the requested order' do
        delete :destroy, params: { id: @order.id }
      end

      it 'redirects to the orders list' do
        delete :destroy, params: { id: @order.id }
        expect(response).to redirect_to(orders_url)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'destroys the requested order' do
        delete :destroy, params: { id: @order.id }
      end

      it 'redirects to the orders list' do
        delete :destroy, params: { id: @order.id }
        expect(response).to redirect_to(orders_url)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'destroys the requested order' do
        delete :destroy, params: { id: @order.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order.id }
        expect(response).to be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested order' do
        delete :destroy, params: { id: @order.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
