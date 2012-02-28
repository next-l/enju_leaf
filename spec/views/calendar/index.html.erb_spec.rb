require 'spec_helper'

describe "calendar/index" do
  fixtures :libraries

  before(:each) do
    FactoryGirl.create(:event, :start_at => 1.day.ago, :end_at => 1.day.from_now)
    FactoryGirl.create(:event, :start_at => 1.day.ago, :end_at => 1.day.from_now, :all_day => true)
    time = Time.zone.now
    assign(:month, time.month)
    assign(:year, time.year)
    assign(:shown_month, time)
    assign(:event_strips, Event.event_strips_for_month(time))
    assign(:libraries, Library.all)
    @ability = Object.new
    @ability.extend(CanCan::Ability)
    controller.stub(:current_ability) { @ability }
  end

  it "renders a list of calendar" do
    render
  end
end
