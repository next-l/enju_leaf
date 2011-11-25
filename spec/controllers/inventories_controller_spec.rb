require 'spec_helper'

describe InventoriesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all inventories as @inventories" do
        get :index
        assigns(:inventories).should eq(Inventory.page(1))
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all inventories as @inventories" do
        get :index
        assigns(:inventories).should eq(Inventory.page(1))
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns all empty as @inventories" do
        get :index
        assigns(:inventories).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all inventories as @inventories" do
        get :index
        assigns(:inventories).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested inventory as @inventory" do
        get :show, :id => 1
        assigns(:inventory).should eq(Inventory.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested inventory as @inventory" do
        get :show, :id => 1
        assigns(:inventory).should eq(Inventory.find(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested inventory as @inventory" do
        get :show, :id => 1
        assigns(:inventory).should eq(Inventory.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested inventory as @inventory" do
        get :show, :id => 1
        assigns(:inventory).should eq(Inventory.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested inventory as @inventory" do
        get :new
        assigns(:inventory).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested inventory as @inventory" do
        get :new
        assigns(:inventory).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested inventory as @inventory" do
        get :new
        assigns(:inventory).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory as @inventory" do
        get :new
        assigns(:inventory).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested inventory as @inventory" do
        inventory = inventories(:inventory_00001)
        get :edit, :id => inventory.id
        assigns(:inventory).should eq(inventory)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested inventory as @inventory" do
        inventory = inventories(:inventory_00001)
        get :edit, :id => inventory.id
        assigns(:inventory).should eq(inventory)
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested inventory as @inventory" do
        inventory = inventories(:inventory_00001)
        get :edit, :id => inventory.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory as @inventory" do
        inventory = inventories(:inventory_00001)
        get :edit, :id => inventory.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
