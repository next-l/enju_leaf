require 'rails_helper'

describe InventoriesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all inventories as @inventories" do
        get :index
        expect(assigns(:inventories)).to eq(Inventory.page(1))
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all inventories as @inventories" do
        get :index
        expect(assigns(:inventories)).to eq(Inventory.page(1))
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all empty as @inventories" do
        get :index
        expect(assigns(:inventories)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns all inventories as @inventories" do
        get :index
        expect(assigns(:inventories)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested inventory as @inventory" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory)).to eq(Inventory.find(1))
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested inventory as @inventory" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory)).to eq(Inventory.find(1))
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested inventory as @inventory" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory)).to eq(Inventory.find(1))
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested inventory as @inventory" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory)).to eq(Inventory.find(1))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
