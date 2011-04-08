require 'spec_helper'

describe ResourceImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all resource_import_files as @resource_import_files" do
        get :index
        assigns(:resource_import_files).should eq(ResourceImportFile.paginate(:page => 1))
      end
    end

    describe "When not logged in" do
      it "assigns all resource_import_files as @resource_import_files" do
        get :index
        assigns(:resource_import_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested resource_import_file as @resource_import_file" do
        get :show, :id => 1
        assigns(:resource_import_file).should eq(ResourceImportFile.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested resource_import_file as @resource_import_file" do
        get :show, :id => 1
        assigns(:resource_import_file).should eq(ResourceImportFile.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested resource_import_file as @resource_import_file" do
        get :new
        assigns(:resource_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested resource_import_file as @resource_import_file" do
        get :new
        assigns(:resource_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested resource_import_file as @resource_import_file" do
        get :new
        assigns(:resource_import_file).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested resource_import_file as @resource_import_file" do
        get :new
        assigns(:resource_import_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested resource_import_file as @resource_import_file" do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, :id => resource_import_file.id
        assigns(:resource_import_file).should eq(resource_import_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested resource_import_file as @resource_import_file" do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, :id => resource_import_file.id
        assigns(:resource_import_file).should eq(resource_import_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested resource_import_file as @resource_import_file" do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, :id => resource_import_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested resource_import_file as @resource_import_file" do
        resource_import_file = resource_import_files(:resource_import_file_00001)
        get :edit, :id => resource_import_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
