require 'spec_helper'
require 'sunspot/rails/spec_helper'

describe OrderListsController do
  disconnect_sunspot

  def valid_attributes
    FactoryGirl.attributes_for(:order_list)
  end

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all order_lists as @order_lists" do
        get :index
        assigns(:order_lists).should eq(OrderList.all)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all order_lists as @order_lists" do
        get :index
        assigns(:order_lists).should eq(OrderList.all)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @order_lists" do
        get :index
        assigns(:order_lists).should be_empty
      end
    end

    describe "When not logged in" do
      it "assigns empty as @order_lists" do
        get :index
        assigns(:order_lists).should be_empty
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :show, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :show, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :show, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end

    describe "When not logged in" do
      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :show, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order_list as @order_list" do
        get :new
        assigns(:order_list).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order_list as @order_list" do
        get :new
        assigns(:order_list).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested order_list as @order_list" do
        get :new
        assigns(:order_list).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested order_list as @order_list" do
        get :new
        assigns(:order_list).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :edit, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :edit, :id => order_list.id
        assigns(:order_list).should eq(order_list)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :edit, :id => order_list.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested order_list as @order_list" do
        order_list = FactoryGirl.create(:order_list)
        get :edit, :id => order_list.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = valid_attributes
      @invalid_attrs = {:bookstore_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "assigns a newly created order_list as @order_list" do
          post :create, :order_list => @attrs
          assigns(:order_list).should be_valid
        end

        it "redirects to the created order_list" do
          post :create, :order_list => @attrs
          response.should redirect_to(order_list_url(assigns(:order_list)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order_list as @order_list" do
          post :create, :order_list => @invalid_attrs
          assigns(:order_list).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :order_list => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "assigns a newly created order_list as @order_list" do
          post :create, :order_list => @attrs
          assigns(:order_list).should be_valid
        end

        it "redirects to the created order_list" do
          post :create, :order_list => @attrs
          response.should redirect_to(order_list_url(assigns(:order_list)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order_list as @order_list" do
          post :create, :order_list => @invalid_attrs
          assigns(:order_list).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :order_list => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "assigns a newly created order_list as @order_list" do
          post :create, :order_list => @attrs
          assigns(:order_list).should be_valid
        end

        it "should be forbidden" do
          post :create, :order_list => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order_list as @order_list" do
          post :create, :order_list => @invalid_attrs
          assigns(:order_list).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :order_list => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created order_list as @order_list" do
          post :create, :order_list => @attrs
          assigns(:order_list).should be_valid
        end

        it "should be forbidden" do
          post :create, :order_list => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved order_list as @order_list" do
          post :create, :order_list => @invalid_attrs
          assigns(:order_list).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :order_list => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @order_list = FactoryGirl.create(:order_list)
      @attrs = valid_attributes
      @invalid_attrs = {:bookstore_id => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

      describe "with valid params" do
        it "updates the requested order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
        end

        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
          assigns(:order_list).should eq(@order_list)
        end
      end

      describe "with invalid params" do
        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      describe "with valid params" do
        it "updates the requested order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
        end

        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
          assigns(:order_list).should eq(@order_list)
          response.should redirect_to(@order_list)
        end
      end

      describe "with invalid params" do
        it "assigns the order_list as @order_list" do
          put :update, :id => @order_list, :order_list => @invalid_attrs
          assigns(:order_list).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @order_list, :order_list => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_user

      describe "with valid params" do
        it "updates the requested order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
        end

        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
          assigns(:order_list).should eq(@order_list)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested order_list" do
          put :update, :id => @order_list.id, :order_list => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @order_list.id, :order_list => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested order_list as @order_list" do
          put :update, :id => @order_list.id, :order_list => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @order_list = FactoryGirl.create(:order_list)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested order_list" do
        delete :destroy, :id => @order_list.id
      end

      it "redirects to the order_lists list" do
        delete :destroy, :id => @order_list.id
        response.should redirect_to(order_lists_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested order_list" do
        delete :destroy, :id => @order_list.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @order_list.id
        response.should redirect_to(order_lists_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested order_list" do
        delete :destroy, :id => @order_list.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @order_list.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested order_list" do
        delete :destroy, :id => @order_list.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @order_list.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
