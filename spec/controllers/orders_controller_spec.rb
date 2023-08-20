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
        assigns(:orders).should eq(Order.page(1))
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns all orders as @orders' do
        get :index
        assigns(:orders).should eq(Order.page(1))
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'should be forbidden' do
        get :index
        assigns(:orders).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'assigns all orders as @orders' do
        get :index
        assigns(:orders).should be_nil
        response.should redirect_to(new_user_session_url)
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
        assigns(:order).should eq(order)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        assigns(:order).should eq(order)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        assigns(:order).should eq(order)
      end
    end

    describe 'When not logged in' do
      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :show, params: { id: order.id }
        assigns(:order).should eq(order)
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
        assigns(:order).should_not be_valid
        response.should be_successful
      end

      it 'should redirect to assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        assigns(:order).should_not be_valid
        response.should be_successful
      end

      it 'assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        assigns(:order).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        assigns(:order).should_not be_valid
        response.should be_successful
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'should not assign the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        assigns(:order).should be_nil
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order as @order' do
        get :new, params: { order_list_id: 1, purchase_request_id: 1 }
        assigns(:order).should be_nil
        response.should redirect_to(new_user_session_url)
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
        assigns(:order).should eq(order)
      end
    end

    describe 'When logged in as Librarian' do
      before(:each) do
        sign_in FactoryBot.create(:librarian)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        assigns(:order).should eq(order)
      end
    end

    describe 'When logged in as User' do
      before(:each) do
        sign_in FactoryBot.create(:user)
      end

      it 'assigns the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'should not assign the requested order as @order' do
        order = FactoryBot.create(:order)
        get :edit, params: { id: order.id }
        response.should redirect_to(new_user_session_url)
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
          assigns(:order).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { order: @attrs }
          response.should redirect_to(assigns(:order))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          assigns(:order).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order: @invalid_attrs }
          response.should render_template('new')
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
          assigns(:order).should be_valid
        end

        it 'redirects to the created agent' do
          post :create, params: { order: @attrs }
          response.should redirect_to(assigns(:order))
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          assigns(:order).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, params: { order: @invalid_attrs }
          response.should render_template('new')
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
          assigns(:order).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @attrs }
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          assigns(:order).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe 'When not logged in' do
      describe 'with valid params' do
        it 'assigns a newly created order as @order' do
          post :create, params: { order: @attrs }
          assigns(:order).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved order as @order' do
          post :create, params: { order: @invalid_attrs }
          assigns(:order).should be_nil
        end

        it 'should be forbidden' do
          post :create, params: { order: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
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
          assigns(:order).should eq(@order)
          response.should redirect_to(@order)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          response.should render_template('edit')
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
          assigns(:order).should eq(@order)
          response.should redirect_to(@order)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          response.should render_template('edit')
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
          assigns(:order).should eq(@order)
          response.should be_forbidden
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          response.should be_forbidden
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
          response.should redirect_to(new_user_session_url)
        end
      end

      describe 'with invalid params' do
        it 'assigns the requested order as @order' do
          put :update, params: { id: @order.id, order: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
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
        response.should redirect_to(orders_url)
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
        response.should redirect_to(orders_url)
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
        response.should be_forbidden
      end
    end

    describe 'When not logged in' do
      it 'destroys the requested order' do
        delete :destroy, params: { id: @order.id }
      end

      it 'should be forbidden' do
        delete :destroy, params: { id: @order.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
