require 'rails_helper'

describe InventoryFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all inventory_files as @inventory_files" do
        get :index
        expect(assigns(:inventory_files)).to eq(InventoryFile.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all inventory_files as @inventory_files" do
        get :index
        expect(assigns(:inventory_files)).to eq(InventoryFile.page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @inventory_files" do
        get :index
        expect(assigns(:inventory_files)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @inventory_files" do
        get :index
        expect(assigns(:inventory_files)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory_file)).to eq(InventoryFile.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory_file)).to eq(InventoryFile.find(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory_file)).to eq(InventoryFile.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested inventory_file as @inventory_file" do
        get :show, params: { id: 1 }
        expect(assigns(:inventory_file)).to eq(InventoryFile.find(1))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested inventory_file as @inventory_file" do
        get :new
        expect(assigns(:inventory_file)).to_not be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        expect(assigns(:inventory_file)).to_not be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        expect(assigns(:inventory_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        expect(assigns(:inventory_file)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should create inventory_file" do
        post :create, params: { inventory_file: { shelf_id: 1, attachment: fixture_file_upload("inventory_file_sample.tsv", 'text/csv') } }
        expect(assigns(:inventory_file)).to be_valid
        expect(assigns(:inventory_file).user.username).to eq @user.username
        expect(response).to redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should be forbidden" do
        post :create, params: { inventory_file: { shelf_id: 1, attachment: fixture_file_upload("inventory_file_sample.tsv", 'text/csv') } }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirect to new session url" do
        post :create, params: { inventory_file: { shelf_id: 1, attachment: fixture_file_upload("inventory_file_sample.tsv", 'text/csv') } }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, params: { id: inventory_file.id }
        expect(assigns(:inventory_file)).to eq(inventory_file)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, params: { id: inventory_file.id }
        expect(assigns(:inventory_file)).to eq(inventory_file)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, params: { id: inventory_file.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, params: { id: inventory_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should update inventory_file" do
        put :update, params: { id: inventory_files(:inventory_file_00003).id, inventory_file: { note: "test" } }
        expect(response).to redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should update inventory_file" do
        put :update, params: { id: inventory_files(:inventory_file_00003).id, inventory_file: { note: "test" } }
        expect(response).to redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not update inventory_file" do
        put :update, params: { id: inventory_files(:inventory_file_00003).id, inventory_file: { note: "test" } }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update inventory_file" do
        put :update, params: { id: inventory_files(:inventory_file_00003).id, inventory_file: { note: "test" } }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @inventory_file = inventory_files(:inventory_file_00001)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested inventory_file" do
        delete :destroy, params: { id: @inventory_file.id }
      end

      it "redirects to the inventory_files list" do
        delete :destroy, params: { id: @inventory_file.id }
        expect(response).to redirect_to(inventory_files_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested inventory_file" do
        delete :destroy, params: { id: @inventory_file.id }
      end

      it "redirects to the inventory_files list" do
        delete :destroy, params: { id: @inventory_file.id }
        expect(response).to redirect_to(inventory_files_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested inventory_file" do
        delete :destroy, params: { id: @inventory_file.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @inventory_file.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested inventory_file" do
        delete :destroy, params: { id: @inventory_file.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @inventory_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
