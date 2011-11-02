require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe OrdersController do
  fixtures :all
  disconnect_sunspot

  describe "GET index" do
    before(:each) do
      FactoryGirl.create(:order)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all orders as @orders" do
        get :index
        assigns(:orders).should eq(Order.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all orders as @orders" do
        get :index
        assigns(:orders).should eq(Order.all)
        response.should be_success
      end

      it "should get index feed" do
        get :index, :format => :rss
        assigns(:orders).should eq(Order.all)
        response.should be_success
      end

      it "should get index with order_list_id" do
        get :index, :order_list_id => 1
        assigns(:orders).should eq(assigns(:order_list).orders.page(1))
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should be forbidden" do
        get :index
        assigns(:orders).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all orders as @orders" do
        get :index
        assigns(:orders).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :show, :id => order.id
        assigns(:order).should eq(order)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :show, :id => order.id
        assigns(:order).should eq(order)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :show, :id => order.id
        assigns(:order).should eq(order)
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :show, :id => order.id
        assigns(:order).should eq(order)
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order as @order" do
        get :new, :order_list_id => 1, :purchase_request_id => 1
        assigns(:order).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order as @order" do
        get :new, :order_list_id => 1, :purchase_request_id => 1
        assigns(:order).should_not be_valid
        response.should be_success
      end

      it "should not get new template without purchase_request_id" do
        get :new
        response.should redirect_to purchase_requests_url
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested order as @order" do
        get :new, :order_list_id => 1, :purchase_request_id => 1
        assigns(:order).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested order as @order" do
        get :new, :order_list_id => 1, :purchase_request_id => 1
        assigns(:order).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :edit, :id => order.id
        assigns(:order).should eq(order)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :edit, :id => order.id
        assigns(:order).should eq(order)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :edit, :id => order.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested order as @order" do
        order = FactoryGirl.create(:order)
        get :edit, :id => order.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:order)
      @invalid_attrs = {:order_list_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created order as @order" do
          post :create, :order => @attrs
          assigns(:order).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :order => @attrs
          response.should redirect_to(assigns(:order))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order as @order" do
          post :create, :order => @invalid_attrs
          assigns(:order).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :order => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created order as @order" do
          post :create, :order => @attrs
          assigns(:order).should be_valid
        end

        it "redirects to the created patron" do
          post :create, :order => @attrs
          response.should redirect_to(assigns(:order))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order as @order" do
          post :create, :order => @invalid_attrs
          assigns(:order).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :order => @invalid_attrs
          response.should render_template("new")
        end
      end

      it "should create order which is not created yet" do
        post :create, :order => { :order_list_id => 1, :purchase_request_id => 5 }
        assigns(:order).should be_valid
        response.should redirect_to order_url(assigns(:order))
      end

      it "should not create order withou order_list_id" do
        post :create, :order => { :purchase_request_id => 1 }
        assigns(:order).should_not be_valid
        response.should be_success
        response.should render_template("new")
      end

      it "should not create order without purchase_request_id" do
        post :create, :order => { :order_list_id => 1 }
        assigns(:order).should_not be_valid
        response.should be_success
        response.should render_template("new")
      end

      it "should not create order which is already created" do
        post :create, :order => { :order_list_id => 1, :purchase_request_id => 1 }
        assigns(:order).should_not be_valid
        response.should be_success
        response.should render_template("new")
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created order as @order" do
          post :create, :order => @attrs
          assigns(:order).should be_valid
        end

        it "should be forbidden" do
          post :create, :order => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order as @order" do
          post :create, :order => @invalid_attrs
          assigns(:order).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :order => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created order as @order" do
          post :create, :order => @attrs
          assigns(:order).should be_valid
        end

        it "should be forbidden" do
          post :create, :order => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order as @order" do
          post :create, :order => @invalid_attrs
          assigns(:order).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :order => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @order = FactoryGirl.create(:order)
      @attrs = FactoryGirl.attributes_for(:order)
      @invalid_attrs = {:order_list_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested order" do
          put :update, :id => @order.id, :order => @attrs
        end

        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @attrs
          assigns(:order).should eq(@order)
          response.should redirect_to(@order)
        end
      end

      describe "with invalid params" do
        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested order" do
          put :update, :id => @order.id, :order => @attrs
        end

        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @attrs
          assigns(:order).should eq(@order)
          response.should redirect_to(@order)
        end
      end

      describe "with invalid params" do
        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested order" do
          put :update, :id => @order.id, :order => @attrs
        end

        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @attrs
          assigns(:order).should eq(@order)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested order" do
          put :update, :id => @order.id, :order => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @order.id, :order => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested order as @order" do
          put :update, :id => @order.id, :order => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @order = FactoryGirl.create(:order)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested order" do
        delete :destroy, :id => @order.id
      end

      it "redirects to the orders list" do
        delete :destroy, :id => @order.id
        response.should redirect_to(orders_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested order" do
        delete :destroy, :id => @order.id
      end

      it "redirects to the orders list" do
        delete :destroy, :id => @order.id
        response.should redirect_to(orders_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested order" do
        delete :destroy, :id => @order.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @order.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested order" do
        delete :destroy, :id => @order.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @order.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
