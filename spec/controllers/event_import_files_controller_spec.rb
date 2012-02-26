# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EventImportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.page(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all event_import_files as @event_import_files" do
        get :index
        assigns(:event_import_files).should eq(EventImportFile.page(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

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
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :show, :id => 1
        assigns(:event_import_file).should eq(EventImportFile.find(1))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
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
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested event_import_file as @event_import_file" do
        get :new
        assigns(:event_import_file).should_not be_valid
        response.should be_success
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
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

  describe "POST create" do
    describe "When logged in as Librarian" do
      before(:each) do
        @user = FactoryGirl.create(:librarian)
        sign_in @user
      end

      it "should create event_import_file" do
        post :create, :event_import_file => {:event_import => fixture_file_upload("/../../examples/event_import_file_sample1.tsv", 'text/csv') }
        assigns(:event_import_file).should be_valid
        assigns(:event_import_file).user.username.should eq @user.username
        response.should redirect_to event_import_file_url(assigns(:event_import_file))
      end

      it "should import user" do
        old_events_count = Event.count
        post :create, :event_import_file => {:event_import => fixture_file_upload("/../../examples/event_import_file_sample2.tsv", 'text/csv') }
        assigns(:event_import_file).import_start
        Event.count.should eq old_events_count + 2
        response.should redirect_to event_import_file_url(assigns(:event_import_file))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      it "should be forbidden" do
        post :create, :event_import_file => {:event_import => fixture_file_upload("/../..//examples/event_import_file_sample1.tsv", 'text/csv') }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirect to new session url" do
        post :create, :event_import_file => {:event_import => fixture_file_upload("/../../examples/event_import_file_sample1.tsv", 'text/csv') }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        assigns(:event_import_file).should eq(event_import_file)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested event_import_file as @event_import_file" do
        event_import_file = event_import_files(:event_import_file_00001)
        get :edit, :id => event_import_file.id
        assigns(:event_import_file).should eq(event_import_file)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
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

  describe "PUT update" do
    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should update event_import_file" do
        put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
        response.should redirect_to event_import_file_url(assigns(:event_import_file))
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not update event_import_file" do
        put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update event_import_file" do
        put :update, :id => event_import_files(:event_import_file_00003).id, :event_import_file => { }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event_import_file = event_import_files(:event_import_file_00001)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
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
        sign_in FactoryGirl.create(:librarian)
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
        sign_in FactoryGirl.create(:user)
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
