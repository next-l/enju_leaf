require 'spec_helper'

describe CalendarController do
  fixtures :all

  describe "GET index", :solr => true do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "assigns all event_stripss as @event_stripss" do
        get :index
        assigns(:event_strips).should_not be_empty
      end
    end

    describe "When not logged in" do
      it "assigns all event_stripss as @event_stripss" do
        get :index
        assigns(:event_strips).should_not be_empty
      end

      it "should get index when a year and a month are set" do
        get :index, :year => 2010, :month => 3
        response.should be_success
        assigns(:event_strips).should_not be_empty
      end

      it "should redirect to a new event if no event is present" do
        get :show, :year => 2010, :month => 3, :day => 1
        response.should redirect_to new_event_path(:date => '2010/03/01')
      end

      it "should redirect to an existing event" do
        get :show, :year => 2008, :month => 1, :day => 13
        response.should redirect_to events_path(:date => '2008/01/13')
      end
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in FactoryGirl.create(:admin)
      end

      it "should redirect to a new event" do
        get :show, :year => '2011', :month => '1', :day => '1'
        response.should redirect_to(new_event_path(:date => '2011/01/01'))
      end
    end

    describe "When not logged in" do
      it "should redirect to a new event" do
        get :show, :year => '2011', :month => '1', :day => '1'
        response.should redirect_to(new_event_path(:date => '2011/01/01'))
      end
    end
  end
end
