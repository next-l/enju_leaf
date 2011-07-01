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

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all patron_import_files as @patron_import_files" do
        get :index
        assigns(:patron_import_files).should eq(PatronImportFile.paginate(:page => 1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns empty as @patron_import_files" do
        get :index
        assigns(:patron_import_files).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @patron_import_files" do
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

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        get :show, :id => 1
        assigns(:patron_import_file).should eq(PatronImportFile.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
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

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        get :new
        assigns(:patron_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested patron_import_file as @patron_import_file" do
        get :new
        assigns(:patron_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested patron_import_file as @patron_import_file" do
        get :new
        assigns(:patron_import_file).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_import_file as @patron_import_file" do
        get :new
        assigns(:patron_import_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        patron_import_file = patron_import_files(:patron_import_file_00001)
        get :edit, :id => patron_import_file.id
        assigns(:patron_import_file).should eq(patron_import_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        patron_import_file = patron_import_files(:patron_import_file_00001)
        get :edit, :id => patron_import_file.id
        assigns(:patron_import_file).should eq(patron_import_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested patron_import_file as @patron_import_file" do
        patron_import_file = patron_import_files(:patron_import_file_00001)
        get :edit, :id => patron_import_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested patron_import_file as @patron_import_file" do
        patron_import_file = patron_import_files(:patron_import_file_00001)
        get :edit, :id => patron_import_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron_import_file = patron_import_files(:patron_import_file_00001)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested patron_import_file" do
        delete :destroy, :id => @patron_import_file.id
      end

      it "redirects to the patron_import_files list" do
        delete :destroy, :id => @patron_import_file.id
        response.should redirect_to(patron_import_files_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested patron_import_file" do
        delete :destroy, :id => @patron_import_file.id
      end

      it "redirects to the patron_import_files list" do
        delete :destroy, :id => @patron_import_file.id
        response.should redirect_to(patron_import_files_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested patron_import_file" do
        delete :destroy, :id => @patron_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron_import_file" do
        delete :destroy, :id => @patron_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
