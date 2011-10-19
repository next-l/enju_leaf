require 'spec_helper'

describe EventsController do
  fixtures :all

  describe "GET index", :solr => true do
    before(:each) do
      FactoryGirl.create(:event)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

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
        get :index, :format => 'rss'
        assigns(:events).should_not be_nil
      end

      it "assigns all events as @events in ics format" do
        get :index, :format => 'ics'
        assigns(:events).should_not be_nil
      end

      it "assigns all events as @events in csv format" do
        get :index, :format => 'csv'
        assigns(:events).should_not be_nil
      end

      it "should get index with library_id" do
        get :index, :library_id => 'kamata'
        response.should be_success
        assigns(:library).should eq libraries(:library_00002)
        assigns(:events).should_not be_nil
      end

      it "should get upcoming event index" do
        get :index, :mode => 'upcoming'
        response.should be_success
        assigns(:events).should_not be_nil
      end

      it "should get past event index" do
        get :index, :mode => 'past'
        response.should be_success
        assigns(:events).should_not be_nil
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When not logged in" do
      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end
  end

  describe "GET new" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "GET edit" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "should not assign the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @attrs = FactoryGirl.attributes_for(:event)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, :event => @attrs
          assigns(:event).should be_valid
        end

        it "redirects to the created event" do
          post :create, :event => @attrs
          response.should redirect_to(assigns(:event))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, :event => @invalid_attrs
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, :event => @attrs
          assigns(:event).should be_valid
        end

        it "redirects to the created event" do
          post :create, :event => @attrs
          response.should redirect_to(assigns(:event))
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, :event => @invalid_attrs
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event => @invalid_attrs
          response.should render_template("new")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, :event => @attrs
          assigns(:event).should be_valid
        end

        it "should be forbidden" do
          post :create, :event => @attrs
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, :event => @invalid_attrs
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "assigns a newly created event as @event" do
          post :create, :event => @attrs
          assigns(:event).should be_valid
        end

        it "should be forbidden" do
          post :create, :event => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns a newly created but unsaved event as @event" do
          post :create, :event => @invalid_attrs
          assigns(:event).should_not be_valid
        end

        it "should be forbidden" do
          post :create, :event => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @attrs = FactoryGirl.attributes_for(:event)
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      describe "with valid params" do
        it "updates the requested event" do
          put :update, :id => @event.id, :event => @attrs
        end

        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @attrs
          assigns(:event).should eq(@event)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      describe "with valid params" do
        it "updates the requested event" do
          put :update, :id => @event.id, :event => @attrs
        end

        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @attrs
          assigns(:event).should eq(@event)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @invalid_attrs
          response.should render_template("edit")
        end
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      describe "with valid params" do
        it "updates the requested event" do
          put :update, :id => @event.id, :event => @attrs
        end

        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @attrs
          assigns(:event).should eq(@event)
          response.should be_forbidden
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @invalid_attrs
          response.should be_forbidden
        end
      end
    end

    describe "When not logged in" do
      describe "with valid params" do
        it "updates the requested event" do
          put :update, :id => @event.id, :event => @attrs
        end

        it "should be forbidden" do
          put :update, :id => @event.id, :event => @attrs
          response.should redirect_to(new_user_session_url)
        end
      end

      describe "with invalid params" do
        it "assigns the requested event as @event" do
          put :update, :id => @event.id, :event => @invalid_attrs
          response.should redirect_to(new_user_session_url)
        end
      end
    end
  end

  describe "DELETE destroy" do
    before(:each) do
      @event = FactoryGirl.create(:event)
    end

    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "redirects to the events list" do
        delete :destroy, :id => @event.id
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as Librarian" do
      before(:each) do
        sign_in FactoryGirl.create(:librarian)
      end

      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "redirects to the events list" do
        delete :destroy, :id => @event.id
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as User" do
      before(:each) do
        sign_in FactoryGirl.create(:user)
      end

      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event.id
        response.should be_forbidden
      end
    end

    describe "When not logged in" do
      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "should be forbidden" do
        delete :destroy, :id => @event.id
        response.should redirect_to(new_user_session_url)
      end
    end
  end
end
