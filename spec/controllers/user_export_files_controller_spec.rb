require 'spec_helper'

describe UserExportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all user_export_files as @user_export_files" do
        get :index
        assigns(:user_export_files).should eq(UserExportFile.order('id DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns nil as @user_export_files" do
        get :index
        assigns(:user_export_files).should be_nil
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns nil as @user_export_files" do
        get :index
        assigns(:user_export_files).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns nil as @user_export_files" do
        get :index
        assigns(:user_export_files).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested user_export_file as @user_export_file" do
        get :show, :id => user_export_files(:user_export_file_00003).id
        assigns(:user_export_file).should eq(user_export_files(:user_export_file_00003))
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested user_export_file as @user_export_file" do
        get :show, :id => user_export_files(:user_export_file_00003).id
        assigns(:user_export_file).should eq(user_export_files(:user_export_file_00003))
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested user_export_file as @user_export_file" do
        get :show, :id => user_export_files(:user_export_file_00003).id
        assigns(:user_export_file).should eq(user_export_files(:user_export_file_00003))
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_export_file as @user_export_file" do
        get :show, :id => user_export_files(:user_export_file_00003).id
        assigns(:user_export_file).should eq(user_export_files(:user_export_file_00003))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested user_export_file as @user_export_file" do
        get :new
        assigns(:user_export_file).should be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested user_export_file as @user_export_file" do
        get :new
        assigns(:user_export_file).should be_valid
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not assign the requested user_export_file as @user_export_file" do
        get :new
        assigns(:user_export_file).should be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_export_file as @user_export_file" do
        get :new
        assigns(:user_export_file).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    describe "When logged in as Administrator" do
      before(:each) do
        @user = FactoryGirl.create(:admin)
        sign_in @user
      end

      it "should create agent_export_file" do
        post :create, :user_export_file => { }
        assigns(:user_export_file).should be_valid
        assigns(:user_export_file).user.username.should eq @user.username
        response.should redirect_to user_export_file_url(assigns(:user_export_file))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should create agent_export_file" do
        post :create, :user_export_file => { }
        assigns(:user_export_file).should_not be_valid
        assigns(:user_export_file).user.should be_nil
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should be forbidden" do
        post :create, :user_export_file => { }
        assigns(:user_export_file).user.should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected to new session url" do
        post :create, :user_export_file => { }
        assigns(:user_export_file).user.should be_nil
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested user_export_file as @user_export_file" do
        user_export_file = user_export_files(:user_export_file_00001)
        get :edit, :id => user_export_file.id
        assigns(:user_export_file).should eq(user_export_file)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested user_export_file as @user_export_file" do
        user_export_file = user_export_files(:user_export_file_00001)
        get :edit, :id => user_export_file.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested user_export_file as @user_export_file" do
        user_export_file = user_export_files(:user_export_file_00001)
        get :edit, :id => user_export_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested user_export_file as @user_export_file" do
        user_export_file = user_export_files(:user_export_file_00001)
        get :edit, :id => user_export_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    describe "When logged in as Administrator" do
      login_admin

      it "should update user_export_file" do
        put :update, :id => user_export_files(:user_export_file_00003).id, :user_export_file => { }
        response.should redirect_to user_export_file_url(assigns(:user_export_file))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should update user_export_file" do
        put :update, :id => user_export_files(:user_export_file_00003).id, :user_export_file => { }
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "should not update user_export_file" do
        put :update, :id => user_export_files(:user_export_file_00003).id, :user_export_file => { }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update user_export_file" do
        put :update, :id => user_export_files(:user_export_file_00003).id, :user_export_file => { }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user_export_file = user_export_files(:user_export_file_00001)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested user_export_file" do
        delete :destroy, :id => @user_export_file.id
      end

      it "redirects to the user_export_files list" do
        delete :destroy, :id => @user_export_file.id
        response.should redirect_to(user_export_files_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested user_export_file" do
        delete :destroy, :id => @user_export_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_export_file.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested user_export_file" do
        delete :destroy, :id => @user_export_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_export_file.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_export_file" do
        delete :destroy, :id => @user_export_file.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_export_file.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
