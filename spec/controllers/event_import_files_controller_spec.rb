# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EventImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.page(1))
      end
    end

    describe "When logged in as User" do
      login_user

      it "assigns empty as @event_import_files" do
        get :index
        assigns(:event_import_files).should be_empty
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @event_import_files" do
        get :index
        assigns(:event_import_files).should be_empty
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_admin

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as User" do
      login_user

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
end
