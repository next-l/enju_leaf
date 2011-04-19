require 'spec_helper'

describe InventoryFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all inventory_files as @inventory_files" do
        get :index
        assigns(:inventory_files).should eq(InventoryFile.paginate(:page => 1))
      end
    end

    describe "When not logged in" do
      it "assigns all inventory_files as @inventory_files" do
        get :index
        assigns(:inventory_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, :id => 1
        assigns(:inventory_file).should eq(InventoryFile.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested inventory_file as @inventory_file" do
        get :show, :id => 1
        assigns(:inventory_file).should eq(InventoryFile.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        assigns(:inventory_file).should eq(inventory_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        assigns(:inventory_file).should eq(inventory_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
