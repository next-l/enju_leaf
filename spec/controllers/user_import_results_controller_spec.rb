# -*- encoding: utf-8 -*-
require 'rails_helper'

describe UserImportResultsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all user_import_results as @user_import_results" do
        get :index
        assigns(:user_import_results).should eq(UserImportResult.page(1))
      end

      describe "With @user_import_file parameter" do
        before(:each) do
          @file = UserImportFile.create user_import: File.new("#{Rails.root}/../../examples/user_import_file_sample_long.tsv"), user: users(:admin)
          @file.default_user_group = UserGroup.find(2)
          @file.default_library = Library.find(3)
          @file.save
          result = @file.import_start
        end
        render_views
        it "should assign all user_import_results for the user_import_file with a page parameter" do
          get :index, user_import_file_id: @file.id
          results = assigns(:user_import_results)
          results.should_not be_empty
          get :index, user_import_file_id: @file.id, page: 2
          results2 = assigns(:user_import_results)
          results2.first.should_not eq results.first
          response.body.should match /<td>11<\/td>/
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all user_import_results as @user_import_results" do
        get :index
        assigns(:user_import_results).should eq(UserImportResult.page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

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
      login_fixture_admin

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, id: 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, id: 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested user_import_result as @user_import_result" do
        get :show, id: 1
        assigns(:user_import_result).should eq(UserImportResult.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested user_import_result as @user_import_result" do
        get :show, id: 1
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
      login_fixture_admin

      it "destroys the requested user_import_result" do
        delete :destroy, id: @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested user_import_result" do
        delete :destroy, id: @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested user_import_result" do
        delete :destroy, id: @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_result.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested user_import_result" do
        delete :destroy, id: @user_import_result.id
      end

      it "should be forbidden" do
        delete :destroy, id: @user_import_result.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
