require 'spec_helper'

describe CalendarController do
  fixtures :all

  describe "GET index" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
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
    end
  end

  describe "GET show" do
    describe "When logged in as Administrator" do
      before(:each) do
        sign_in Factory(:admin)
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
