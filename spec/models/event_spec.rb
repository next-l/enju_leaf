# -*- encoding: utf-8 -*-
require 'spec_helper'

describe Event do
  fixtures :events

  it "should set_all_day" do
    event = events(:event_00001)
    event.all_day = true
    event.set_all_day
    event.all_day.should be_true
  end

  it "should set all_day and beginning_of_day" do
    event = events(:event_00008)
    event.all_day = true
    event.set_all_day
    event.start_at.should eq event.end_at.beginning_of_day
  end
end
