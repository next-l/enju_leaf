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
end
