require 'rails_helper'

describe EventExportFilesController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all event_export_files as @event_export_files" do
        get :index
        expect(assigns(:event_export_files)).to eq(EventExportFile.order('id DESC').page(1))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all event_export_files as @event_export_files" do
        get :index
        expect(assigns(:event_export_files)).to eq(EventExportFile.order('id DESC').page(1))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns empty as @event_export_files" do
        get :index
        expect(assigns(:event_export_files)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns empty as @event_export_files" do
        get :index
        expect(assigns(:event_export_files)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_export_file as @event_export_file" do
        get :show, params: { id: event_export_files(:event_export_file_00003).id }
        expect(assigns(:event_export_file)).to eq(event_export_files(:event_export_file_00003))
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event_export_file as @event_export_file" do
        get :show, params: { id: event_export_files(:event_export_file_00003).id }
        expect(assigns(:event_export_file)).to eq(event_export_files(:event_export_file_00003))
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event_export_file as @event_export_file" do
        get :show, params: { id: event_export_files(:event_export_file_00003).id }
        expect(assigns(:event_export_file)).to eq(event_export_files(:event_export_file_00003))
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "assigns the requested event_export_file as @event_export_file" do
        get :show, params: { id: event_export_files(:event_export_file_00003).id }
        expect(assigns(:event_export_file)).to eq(event_export_files(:event_export_file_00003))
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_export_file as @event_export_file" do
        get :new
        expect(assigns(:event_export_file)).to be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested event_export_file as @event_export_file" do
        get :new
        expect(assigns(:event_export_file)).to be_valid
        expect(response).to be_successful
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested event_export_file as @event_export_file" do
        get :new
        expect(assigns(:event_export_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_export_file as @event_export_file" do
        get :new
        expect(assigns(:event_export_file)).to be_nil
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should create agent_export_file" do
        post :create, params: { event_export_file: { event_export_file_name: 'test.txt' } }
        expect(assigns(:event_export_file)).to be_valid
        expect(assigns(:event_export_file).user.username).to eq @user.username
        expect(response).to redirect_to event_export_file_url(assigns(:event_export_file))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should be forbidden" do
        post :create, params: { event_export_file: { event_export_file_name: 'test.txt' } }
        expect(assigns(:event_export_file)).to be_nil
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should be redirected to new session url" do
        post :create, params: { event_export_file: { event_export_file_name: 'test.txt' } }
        expect(assigns(:event_export_file)).to be_nil
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event_export_file as @event_export_file" do
        event_export_file = event_export_files(:event_export_file_00001)
        get :edit, params: { id: event_export_file.id }
        expect(assigns(:event_export_file)).to eq(event_export_file)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event_export_file as @event_export_file" do
        event_export_file = event_export_files(:event_export_file_00001)
        get :edit, params: { id: event_export_file.id }
        expect(assigns(:event_export_file)).to eq(event_export_file)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event_export_file as @event_export_file" do
        event_export_file = event_export_files(:event_export_file_00001)
        get :edit, params: { id: event_export_file.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event_export_file as @event_export_file" do
        event_export_file = event_export_files(:event_export_file_00001)
        get :edit, params: { id: event_export_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "PUT update" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "should update event_export_file" do
        put :update, params: { id: event_export_files(:event_export_file_00003).id, event_export_file: { event_export_file_name: 'test.txt' } }
        expect(response).to redirect_to event_export_file_url(assigns(:event_export_file))
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should update event_export_file" do
        put :update, params: { id: event_export_files(:event_export_file_00003).id, event_export_file: { event_export_file_name: 'test.txt' } }
        expect(response).to redirect_to event_export_file_url(assigns(:event_export_file))
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not update event_export_file" do
        put :update, params: { id: event_export_files(:event_export_file_00003).id, event_export_file: {} }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not update event_export_file" do
        put :update, params: { id: event_export_files(:event_export_file_00003).id, event_export_file: {} }
        expect(response).to redirect_to new_user_session_url
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event_export_file = event_export_files(:event_export_file_00001)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested event_export_file" do
        delete :destroy, params: { id: @event_export_file.id }
      end

      it "redirects to the event_export_files list" do
        delete :destroy, params: { id: @event_export_file.id }
        expect(response).to redirect_to(event_export_files_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested event_export_file" do
        delete :destroy, params: { id: @event_export_file.id }
      end

      it "redirects to the event_export_files list" do
        delete :destroy, params: { id: @event_export_file.id }
        expect(response).to redirect_to(event_export_files_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested event_export_file" do
        delete :destroy, params: { id: @event_export_file.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event_export_file.id }
        expect(response).to be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event_export_file" do
        delete :destroy, params: { id: @event_export_file.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event_export_file.id }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end
end
