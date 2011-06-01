# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EventImportFile do
  #pending "add some examples to (or delete) #{__FILE__}"
  before(:each) do
    @file = EventImportFile.create :event_import => File.new("#{Rails.root.to_s}/examples/event_import_file_sample1.tsv")
  end

  it "should be imported" do
    closing_days_size = Event.closing_days.size
    @file.import_start.should eq({:imported => 3, :failed => 0})
    Event.closing_days.size.should eq closing_days_size + 1
  end
end
