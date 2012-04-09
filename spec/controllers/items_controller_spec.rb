# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ItemsController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When not logged in" do
      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end
  end

  describe "GET new" do
    before(:each) do
      @manifestation = FactoryGirl.create(:manifestation)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      manifestation = FactoryGirl.create(:manifestation)
      @attrs = FactoryGirl.attributes_for(:item, :manifestation_id => manifestation.id)
      @invalid_attrs = {:item_identifier => '無効なID', :manifestation_id => manifestation.id}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created item as @item" do
          post :create, :item => @attrs
          assigns(:item).should be_valid
        end

        it "redirects to the created item" do
          post :create, :item => @attrs
          response.should redirect_to(item_url(assigns(:item)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved item as @item" do
          post :create, :item => @invalid_attrs
          assigns(:item).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :item => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created item as @item" do
          post :create, :item => @attrs
          assigns(:item).should be_valid
        end

        it "redirects to the created item" do
          post :create, :item => @attrs
          response.should redirect_to(item_url(assigns(:item)))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved item as @item" do
          post :create, :item => @invalid_attrs
          assigns(:item).should_not be_valid
        end

        it "re-renders the 'new' template" do
          post :create, :item => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created item as @item" do
          post :create, :item => @attrs
          assigns(:item).should be_valid
        end

        it "should be forbidden" do
          post :create, :item => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved item as @item" do
          post :create, :item => @invalid_attrs
          assigns(:item).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :item => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created item as @item" do
          post :create, :item => @attrs
          assigns(:item).should be_valid
        end

        it "should be forbidden" do
          post :create, :item => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved item as @item" do
          post :create, :item => @invalid_attrs
          assigns(:item).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :item => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @item = FactoryGirl.create(:item)
      @attrs = FactoryGirl.attributes_for(:item)
      @invalid_attrs = {:item_identifier => '無効なID'}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested item" do
          put :update, :id => @item.id, :item => @attrs
        end

        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @attrs
          assigns(:item).should eq(@item)
        end
      end

      describe "with invalid params" do
        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @invalid_attrs
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @item, :item => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested item" do
          put :update, :id => @item.id, :item => @attrs
        end

        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @attrs
          assigns(:item).should eq(@item)
          response.should redirect_to(@item)
        end
      end

      describe "with invalid params" do
        it "assigns the item as @item" do
          put :update, :id => @item, :item => @invalid_attrs
          assigns(:item).should_not be_valid
        end

        it "re-renders the 'edit' template" do
          put :update, :id => @item, :item => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested item" do
          put :update, :id => @item.id, :item => @attrs
        end

        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @attrs
          assigns(:item).should eq(@item)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested item" do
          put :update, :id => @item.id, :item => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @item.id, :item => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested item as @item" do
          put :update, :id => @item.id, :item => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @item = items(:item_00006)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested item" do
        delete :destroy, :id => @item.id
      end

      it "redirects to the items list" do
        delete :destroy, :id => @item.id
        #response.should redirect_to(items_url)
        response.should  redirect_to(manifestation_items_url(@item.manifestation))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested item" do
        delete :destroy, :id => @item.id
      end

      it "redirects to the items list" do
        delete :destroy, :id => @item.id
        #response.should redirect_to(items_url)
        response.should  redirect_to(manifestation_items_url(@item.manifestation))
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested item" do
        delete :destroy, :id => @item.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @item.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested item" do
        delete :destroy, :id => @item.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @item.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
