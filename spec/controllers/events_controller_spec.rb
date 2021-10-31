require 'rails_helper'

describe EventsController do
  fixtures :all

  describe "GET index", solr: true do
    before do
      Event.reindex
    end

    before(:each) do
      FactoryBot.create(:event)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When not logged in" do
      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end

      it "assigns all events as @events in rss format" do
        get :index, format: 'rss'
        assigns(:events).should_not be_nil
      end

      it "assigns all events as @events in ics format" do
        get :index, format: 'ics'
        assigns(:events).should_not be_nil
      end

      it "assigns all events as @events in text format" do
        get :index, format: :text
        assigns(:events).should_not be_nil
      end

      it "should get index with library_id" do
        get :index, params: { library_id: 'kamata' }
        response.should be_successful
        assigns(:library).should eq libraries(:library_00002)
        assigns(:events).should_not be_nil
      end

      it "should get upcoming event index" do
        get :index, params: { mode: 'upcoming' }
        response.should be_successful
        assigns(:events).should_not be_nil
      end

      it "should get past event index" do
        get :index, params: { mode: 'past' }
        response.should be_successful
        assigns(:events).should_not be_nil
      end

      describe "with json data (calendar feed)" do
        render_views
        it "should get all events data" do
          20.times do |c|
            FactoryBot.create(:event)
          end
          Event.reindex
          today = Date.today
          get :index, params: { format: "json", start: today.beginning_of_month.to_s, end: today.end_of_month.to_s }
          expect(response).to be_successful
          events = assigns(:events)
          expect(events).not_to be_nil
          expect(events.size).to be >= 20
          expect(response.body).to match /\A\[/
          data = JSON.parse(response.body)
          expect(data.first).not_to be_nil
          expect(data.first).to have_key("start")
          expect(data.first).to have_key("url")
        end
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :show, params: { id: event.id }
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :show, params: { id: event.id }
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :show, params: { id: event.id }
        assigns(:event).should eq(event)
      end
    end

    describe "When not logged in" do
      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :show, params: { id: event.id }
        assigns(:event).should eq(event)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should be_nil
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should be_nil
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      login_fixture_admin

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.id }
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.id }
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "assigns the requested event as @event" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event as @event" do
        event = FactoryBot.create(:event)
        get :edit, params: { id: event.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryBot.attributes_for(:event)
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, params: { event: @attrs }
          assigns(:event).should be_valid
        end

        it "redirects to the created event" do
          post :create, params: { event: @attrs }
          response.should redirect_to(assigns(:event))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, params: { event: @invalid_attrs }
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, params: { event: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, params: { event: @attrs }
          assigns(:event).should be_valid
        end

        it "redirects to the created event" do
          post :create, params: { event: @attrs }
          response.should redirect_to(assigns(:event))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, params: { event: @invalid_attrs }
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, params: { event: @invalid_attrs }
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, params: { event: @attrs }
          assigns(:event).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event: @attrs }
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, params: { event: @invalid_attrs }
          assigns(:event).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, params: { event: @attrs }
          assigns(:event).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, params: { event: @invalid_attrs }
          assigns(:event).should be_nil
        end

        it "should be forbidden" do
          post :create, params: { event: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @event = FactoryBot.create(:event)
      @attrs = FactoryBot.attributes_for(:event)
      @invalid_attrs = {name: ''}
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      describe "with valid params" do
        it "updates the requested event" do
          put :update, params: { id: @event.id, event: @attrs }
        end

        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @attrs }
          assigns(:event).should eq(@event)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      describe "with valid params" do
        it "updates the requested event" do
          put :update, params: { id: @event.id, event: @attrs }
        end

        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @attrs }
          assigns(:event).should eq(@event)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @invalid_attrs }
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      describe "with valid params" do
        it "updates the requested event" do
          put :update, params: { id: @event.id, event: @attrs }
        end

        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @attrs }
          assigns(:event).should eq(@event)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @invalid_attrs }
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested event" do
          put :update, params: { id: @event.id, event: @attrs }
        end

        it "should be forbidden" do
          put :update, params: { id: @event.id, event: @attrs }
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, params: { id: @event.id, event: @invalid_attrs }
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event = FactoryBot.create(:event)
    end

    describe "When logged in as Administrator" do
      login_fixture_admin

      it "destroys the requested event" do
        delete :destroy, params: { id: @event.id }
      end

      it "redirects to the events list" do
        delete :destroy, params: { id: @event.id }
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as Librarian" do
      login_fixture_librarian

      it "destroys the requested event" do
        delete :destroy, params: { id: @event.id }
      end

      it "redirects to the events list" do
        delete :destroy, params: { id: @event.id }
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as User" do
      login_fixture_user

      it "destroys the requested event" do
        delete :destroy, params: { id: @event.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event.id }
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event" do
        delete :destroy, params: { id: @event.id }
      end

      it "should be forbidden" do
        delete :destroy, params: { id: @event.id }
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
