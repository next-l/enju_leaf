# -*- encoding: utf-8 -*-
require 'spec_helper'

describe InventoryFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all inventory_files as @inventory_files" do
        get :index
        assigns(:inventory_files).should eq(InventoryFile.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all inventory_files as @inventory_files" do
        get :index
        assigns(:inventory_files).should eq(InventoryFile.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @inventory_files" do
        get :index
        assigns(:inventory_files).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @inventory_files" do
        get :index
        assigns(:inventory_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, :id => 1
        assigns(:inventory_file).should eq(InventoryFile.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested inventory_file as @inventory_file" do
        get :show, :id => 1
        assigns(:inventory_file).should eq(InventoryFile.find(1))
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested inventory_file as @inventory_file" do
        get :new
        assigns(:inventory_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      login_user

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

  describe "POST create" do
    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should create inventory_file" do
        post :create, :inventory_file => {:inventory => fixture_file_upload("/../../examples/inventory_file_sample.tsv", 'text/csv') }
        assigns(:inventory_file).save!
        assigns(:inventory_file).should be_valid
        assigns(:inventory_file).user.username.should eq @user.username
        response.should redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should be forbidden" do
        post :create, :inventory_file => {:inventory => fixture_file_upload("/../../examples/inventory_file_sample.tsv", 'text/csv') }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirect to new session url" do
        post :create, :inventory_file => {:inventory => fixture_file_upload("/../../examples/inventory_file_sample.tsv", 'text/csv') }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        assigns(:inventory_file).should eq(inventory_file)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested inventory_file as @inventory_file" do
        inventory_file = inventory_files(:inventory_file_00001)
        get :edit, :id => inventory_file.id
        assigns(:inventory_file).should eq(inventory_file)
      end
    end

    describe "When logged in as User" do
      login_user

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

  describe "PUT update" do
    describe "When logged in as Administrator" do
      login_admin

      it "should update inventory_file" do
        put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
        response.should redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should update inventory_file" do
        put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
        response.should redirect_to inventory_file_url(assigns(:inventory_file))
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not update inventory_file" do
        put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update inventory_file" do
        put :update, :id => inventory_files(:inventory_file_00003).id, :inventory_file => { }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @inventory_file = inventory_files(:inventory_file_00001)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested inventory_file" do
        delete :destroy, :id => @inventory_file.id
      end

      it "redirects to the inventory_files list" do
        delete :destroy, :id => @inventory_file.id
        response.should redirect_to(inventory_files_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested inventory_file" do
        delete :destroy, :id => @inventory_file.id
      end

      it "redirects to the inventory_files list" do
        delete :destroy, :id => @inventory_file.id
        response.should redirect_to(inventory_files_url)
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested inventory_file" do
        delete :destroy, :id => @inventory_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @inventory_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested inventory_file" do
        delete :destroy, :id => @inventory_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @inventory_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
