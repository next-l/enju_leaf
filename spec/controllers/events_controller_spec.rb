require 'spec_helper'

describe EventsController do
  fixtures :all

  def valid_attributes
    FactoryGirl.attributes_for(:event)
  end

  describe "GET index", :solr => true do
    before do
      Event.reindex
    end

    before(:each) do
      FactoryGirl.create(:event)
    end

    describe "When logged in as Administrator" do
      login_admin

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns all events as @events" do
        get :index
        assigns(:events).should_not be_nil
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :show, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "should not assign the requested event as @event" do
        get :new
        assigns(:event).should_not be_valid
      end

      it "should get new with date" do
        get :new, :date => '2010/09/01'
        response.should be_success
        assigns(:event).should_not be_valid
      end

      it "should get new without invalid date" do
        get :new, :date => '2010/13/01'
        response.should be_success
        flash[:notice].should eq I18n.t('page.invalid_date')
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
        assigns(:event).should eq(event)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "assigns the requested event as @event" do
        event = FactoryGirl.create(:event)
        get :edit, :id => event.id
      end
    end

    describe "When logged in as User" do
      login_user

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
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

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

        it "should render new template" do
          post :create, :event => @invalid_attrs
          response.should render_template("new")
        end
      end

      it "should create event" do
        post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should redirect_to event_url(assigns(:event))
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

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

        it "should render new template" do
          post :create, :event => @invalid_attrs
          response.should render_template("new")
        end
      end

      it "should create event without library_id" do
        post :create, :event => { :name => 'test', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should redirect_to event_url(assigns(:event))
      end

      it "should create event without category_id" do
        post :create, :event => { :name => 'test', :library_id => '1', :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should redirect_to event_url(assigns(:event))
      end

      it "should not create event with_invalid_dates" do
        post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-08', :end_at => '2008-02-05' }
        response.should be_success
        assigns(:event).errors['start_at'].should be_true
      end

      it "should creat event" do
        post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should redirect_to event_url(assigns(:event))
      end
    end

    describe "When logged in as User" do
      login_user

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

      it "should not creat event" do
        post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should be_forbidden
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

      it "should not create event" do
        post :create, :event => { :name => 'test', :library_id => '1', :event_category_id => 1, :start_at => '2008-02-05', :end_at => '2008-02-08' }
        response.should redirect_to new_user_session_url
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      @event = FactoryGirl.create(:event)
      @attrs = valid_attributes
      @invalid_attrs = {:name => ''}
    end

    describe "When logged in as Administrator" do
      login_admin

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
      login_librarian

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

      it "should not update event without library_id" do
        put :update, :id => 1, :event => {:library_id => nil}
        response.should be_success
      end
  
      it "should update event without event_category_id" do
        put :update, :id => 1, :event => {:event_category_id => nil}
        response.should be_success
      end
  
      it "should not update event with invalid date" do
        put :update, :id => 1, :event => {:start_at => '2008-02-08', :end_at => '2008-02-05' }
        response.should be_success
        assigns(:event).errors['start_at'].should be_true
      end
    end

    describe "When logged in as User" do
      login_user

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
      login_admin

      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "redirects to the events list" do
        delete :destroy, :id => @event.id
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as Librarian" do
      login_librarian

      it "destroys the requested event" do
        delete :destroy, :id => @event.id
      end

      it "redirects to the events list" do
        delete :destroy, :id => @event.id
        response.should redirect_to(events_url)
      end
    end

    describe "When logged in as User" do
      login_user

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
