require 'rails_helper'

describe EventImportResultsController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all event_import_results as @event_import_results" do
        get :index
        assigns(:event_import_results).should eq(EventImportResult.order(created_at: :desc).page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all event_import_results as @event_import_results" do
        get :index
        assigns(:event_import_results).should eq(EventImportResult.order(created_at: :desc).page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @event_import_results" do
        get :index
        assigns(:event_import_results).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @event_import_results" do
        get :index
        assigns(:event_import_results).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_import_result as @event_import_result" do
        get :show, params: { id: 1 }
        assigns(:event_import_result).should eq(EventImportResult.find(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event_import_result as @event_import_result" do
        get :show, params: { id: 1 }
        assigns(:event_import_result).should eq(EventImportResult.find(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event_import_result as @event_import_result" do
        get :show, params: { id: 1 }
        assigns(:event_import_result).should eq(EventImportResult.find(1))
      end
    end

    describe "When not logged in" do
      it "assigns the requested event_import_result as @event_import_result" do
        get :show, params: { id: 1 }
        assigns(:event_import_result).should eq(EventImportResult.find(1))
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
