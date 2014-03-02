# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserImportResultsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all user_import_results as @user_import_results" do
        get :index
        assigns(:user_import_results).should eq(UserImportResult.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all user_import_results as @user_import_results" do
        get :index
        assigns(:user_import_results).should eq(UserImportResult.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @user_import_results" do
        get :index
        assigns(:user_import_results).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @user_import_results" do
        get :index
        assigns(:user_import_results).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, :id => 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, :id => 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, :id => 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_import_result as @user_import_result" do
        get :show, :id => 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @user_import_result = user_import_results(:one)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested user_import_result" do
        delete :destroy, :id => @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested user_import_result" do
        delete :destroy, :id => @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested user_import_result" do
        delete :destroy, :id => @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_import_result" do
        delete :destroy, :id => @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @user_import_result.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
