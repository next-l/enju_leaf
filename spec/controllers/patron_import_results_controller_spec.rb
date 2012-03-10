# -*- encoding: utf-8 -*-
require 'spec_helper'

describe PatronImportResultsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all patron_import_results as @patron_import_results" do
        get :index
        assigns(:patron_import_results).should eq(PatronImportResult.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all patron_import_results as @patron_import_results" do
        get :index
        assigns(:patron_import_results).should eq(PatronImportResult.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @patron_import_results" do
        get :index
        assigns(:patron_import_results).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @patron_import_results" do
        get :index
        assigns(:patron_import_results).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested patron_import_result as @patron_import_result" do
        get :show, :id => 1
        assigns(:patron_import_result).should eq(PatronImportResult.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested patron_import_result as @patron_import_result" do
        get :show, :id => 1
        assigns(:patron_import_result).should eq(PatronImportResult.find(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns the requested patron_import_result as @patron_import_result" do
        get :show, :id => 1
        assigns(:patron_import_result).should eq(PatronImportResult.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested patron_import_result as @patron_import_result" do
        get :show, :id => 1
        assigns(:patron_import_result).should eq(PatronImportResult.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @patron_import_result = patron_import_results(:one)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "destroys the requested patron_import_result" do
        delete :destroy, :id => @patron_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested patron_import_result" do
        delete :destroy, :id => @patron_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_user

      it "destroys the requested patron_import_result" do
        delete :destroy, :id => @patron_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_result.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested patron_import_result" do
        delete :destroy, :id => @patron_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @patron_import_result.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
