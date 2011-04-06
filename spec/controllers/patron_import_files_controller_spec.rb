require 'spec_helper'

describe PatronImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all patron_import_files as @patron_import_files" do
        get :index
        assigns(:patron_import_files).should eq(PatronImportFile.paginate(:page => 1))
      end
    end

    describe "When not logged in" do
      it "assigns all patron_import_files as @patron_import_files" do
        get :index
        assigns(:patron_import_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        get :show, :id => 1
        assigns(:patron_import_file).should eq(PatronImportFile.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron_import_file as @patron_import_file" do
        get :show, :id => 1
        assigns(:patron_import_file).should eq(PatronImportFile.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
