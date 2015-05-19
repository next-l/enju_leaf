require 'spec_helper'

describe UserImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all user_import_files as @user_import_files" do
        get :index
        assigns(:user_import_files).should eq(UserImportFile.order(id: :desc).page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all user_import_files as @user_import_files" do
        get :index
        assigns(:user_import_files).should eq(UserImportFile.order(id: :desc).page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @user_import_files" do
        get :index
        assigns(:user_import_files).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @user_import_files" do
        get :index
        assigns(:user_import_files).should be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_import_file as @user_import_file" do
        get :show, id: user_import_files(:two).id
        assigns(:user_import_file).should eq(user_import_files(:two))
        expect(response).to be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_import_file as @user_import_file" do
        get :show, id: user_import_files(:two).id
        assigns(:user_import_file).should eq(user_import_files(:two))
        expect(response).to be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user_import_file as @user_import_file" do
        get :show, id: user_import_files(:two).id
        assigns(:user_import_file).should eq(user_import_files(:two))
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_import_file as @user_import_file" do
        get :show, id: user_import_files(:two).id
        assigns(:user_import_file).should eq(user_import_files(:two))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_import_file as @user_import_file" do
        get :new
        assigns(:user_import_file).should_not be_valid
        expect(response).to be_success
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_import_file as @user_import_file" do
        get :new
        assigns(:user_import_file).should_not be_valid
        expect(response).to be_success
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested user_import_file as @user_import_file" do
        get :new
        assigns(:user_import_file).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_import_file as @user_import_file" do
        get :new
        assigns(:user_import_file).should be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    describe "When logged in as Librarian" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:librarian)
        @user.profile = profile
        sign_in @user
      end

      it "should create agent_import_file" do
        post :create, user_import_file: { user_import: fixture_file_upload("/../../examples/user_import_file_sample.tsv", 'text/csv') }
        assigns(:user_import_file).should be_valid
        assigns(:user_import_file).user.username.should eq @user.username
        expect(response).to redirect_to user_import_file_url(assigns(:user_import_file))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        profile = FactoryGirl.create(:profile)
        @user = FactoryGirl.create(:user)
        @user.profile = profile
        sign_in @user
      end

      it "should be forbidden" do
        post :create, user_import_file: { user_import: fixture_file_upload("/../../examples/user_import_file_sample.tsv", 'text/csv') }
        assigns(:user_import_file).should be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected to new session url" do
        post :create, user_import_file: { user_import: fixture_file_upload("/../../examples/user_import_file_sample.tsv", 'text/csv') }
        assigns(:user_import_file).should be_nil
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested user_import_file as @user_import_file" do
        user_import_file = user_import_files(:one)
        get :edit, id: user_import_file.id
        assigns(:user_import_file).should eq(user_import_file)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_import_file as @user_import_file" do
        user_import_file = user_import_files(:one)
        get :edit, id: user_import_file.id
        assigns(:user_import_file).should eq(user_import_file)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user_import_file as @user_import_file" do
        user_import_file = user_import_files(:one)
        get :edit, id: user_import_file.id
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_import_file as @user_import_file" do
        user_import_file = user_import_files(:one)
        get :edit, id: user_import_file.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should update user_import_file" do
        post :create, user_import_file: { user_import: fixture_file_upload("/../../examples/user_import_file_sample.tsv", 'text/csv') }
        put :update, id: assigns(:user_import_file).id, user_import_file: { :note => 'test' }
        expect(response).to redirect_to user_import_file_url(assigns(:user_import_file))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should update user_import_file" do
        post :create, user_import_file: { user_import: fixture_file_upload("/../../examples/user_import_file_sample.tsv", 'text/csv') }
        put :update, id: assigns(:user_import_file).id, user_import_file: { :note => 'test' }
        expect(response).to redirect_to user_import_file_url(assigns(:user_import_file))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not update user_import_file" do
        put :update, id: user_import_files(:two).id, user_import_file: { }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update user_import_file" do
        put :update, id: user_import_files(:two).id, user_import_file: { }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user_import_file = user_import_files(:one)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested user_import_file" do
        delete :destroy, id: @user_import_file.id
      end

      it "redirects to the user_import_files list" do
        delete :destroy, id: @user_import_file.id
        expect(response).to redirect_to(user_import_files_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user_import_file" do
        delete :destroy, id: @user_import_file.id
      end

      it "redirects to the user_import_files list" do
        delete :destroy, id: @user_import_file.id
        expect(response).to redirect_to(user_import_files_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user_import_file" do
        delete :destroy, id: @user_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_file.id
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_import_file" do
        delete :destroy, id: @user_import_file.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_file.id
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
