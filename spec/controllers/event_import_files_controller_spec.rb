require 'spec_helper'

describe EventImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.paginate(:page => 1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.paginate(:page => 1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns all event_import_files as @event_import_files" do
        get :index
        response.should be_forbidden
        assigns(:event_import_files).should eq(EventImportFile.paginate(:page => 1))
      end
    end

    describe "When not logged in" do
      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "should not assign the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "should not assign the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        assigns(:event_import_file).should eq(event_import_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        assigns(:event_import_file).should eq(event_import_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event_import_file = event_import_files(:event_import_file_00001)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
      end

      it "destroys the requested event_import_file" do
        delete :destroy, :id => @event_import_file.id
      end

      it "redirects to the event_import_files list" do
        delete :destroy, :id => @event_import_file.id
        response.should redirect_to(event_import_files_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in Factory(:librarian)
      end

      it "destroys the requested event_import_file" do
        delete :destroy, :id => @event_import_file.id
      end

      it "redirects to the event_import_files list" do
        delete :destroy, :id => @event_import_file.id
        response.should redirect_to(event_import_files_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in Factory(:user)
      end

      it "destroys the requested event_import_file" do
        delete :destroy, :id => @event_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event_import_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event_import_file" do
        delete :destroy, :id => @event_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event_import_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
