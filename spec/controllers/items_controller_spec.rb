# -*- encoding: utf-8 -*-
require 'spec_helper'

describe ItemsController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:item)
  end

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end

      it "should not get index with inventory_file_id" do
        get :index, :inventory_file_id => 1
        response.should be_success
        assigns(:inventory_file).should eq InventoryFile.find(1)
        assigns(:items).should eq Item.inventory_items(assigns(:inventory_file), 'not_on_shelf').order('items.id').page(1)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end

      it "should not get index with inventory_file_id" do
        get :index, :inventory_file_id => 1
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all items as @items" do
        get :index
        assigns(:items).should_not be_nil
      end

      it "should get index with patron_id" do
        get :index, :patron_id => 1
        response.should be_success
        assigns(:patron).should eq Patron.find(1)
        assigns(:items).should eq assigns(:patron).items.order('created_at DESC').page(1)
      end

      it "should get index with manifestation_id" do
        get :index, :manifestation_id => 1
        response.should be_success
        assigns(:manifestation).should eq Manifestation.find(1)
        assigns(:items).should eq assigns(:manifestation).items.order('created_at DESC').page(1)
      end

      it "should get index with shelf_id" do
        get :index, :shelf_id => 1
        response.should be_success
        assigns(:shelf).should eq Shelf.find(1)
        assigns(:items).should eq assigns(:shelf).items.order('created_at DESC').page(1)
      end

      it "should not get index with inventory_file_id" do
        get :index, :inventory_file_id => 1
        response.should redirect_to new_user_session_url
        assigns(:inventory_file).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end

      it "should not show missing item" do
        get :show, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :show, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should be_success
      end

      it "should not get new without manifestation_id" do
        get :new
        response.should redirect_to(manifestations_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested item as @item" do
        get :new, :manifestation_id => @manifestation.id
        assigns(:item).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        assigns(:item).should eq(item)
      end

      it "should not edit missing item" do
        get :edit, :id => 'missing'
        response.should be_missing
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested item as @item" do
        item = FactoryGirl.create(:item)
        get :edit, :id => item.id
        assigns(:item).should eq(item)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      describe "with valid params" do
        it "assigns a newly created item as @item" do
          post :create, :item => @attrs
          assigns(:item).should be_valid
        end

        it "redirects to the created item" do
          post :create, :item => @attrs
          assigns(:item).manifestation.should_not be_nil
          response.should redirect_to(item_url(assigns(:item)))
        end

        it "should create a lending policy" do
          old_lending_policy_count = LendingPolicy.count
          post :create, :item => @attrs
          LendingPolicy.count.should eq old_lending_policy_count + UserGroup.count
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

      it "should not create item without manifestation_id" do
        post :create, :item => { :circulation_status_id => 1 }
        response.should be_missing
      end

      it "should not create item already created" do
        post :create, :item => { :circulation_status_id => 1, :item_identifier => "00001", :manifestation_id => 1}
        assigns(:item).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

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

      it "should create reserved item" do
        post :create, :item => { :circulation_status_id => 1, :manifestation_id => 2}
        assigns(:item).should be_valid

        response.should redirect_to item_url(assigns(:item))
        flash[:message].should eq I18n.t('item.this_item_is_reserved')
        assigns(:item).manifestation.should eq Manifestation.find(2)
        assigns(:item).manifestation.next_reservation.state.should eq 'retained'
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

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
      login_librarian

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
      login_user

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
        response.should redirect_to(manifestation_items_url(@item.manifestation))
      end

      it "should not destroy missing item" do
        delete :destroy, :id => 'missing'
        response.should be_missing
      end

      it "should not destroy item if not checked in" do
        delete :destroy, :id => 1
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested item" do
        delete :destroy, :id => @item.id
      end

      it "redirects to the items list" do
        delete :destroy, :id => @item.id
        response.should redirect_to(manifestation_items_url(@item.manifestation))
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
