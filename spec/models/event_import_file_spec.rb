# -*- encoding: utf-8 -*-
require 'spec_helper'

describe EventImportFile do
  #pending "add some examples to (or delete) #{__FILE__}"

  describe "When it is written in utf-8" do
    before(:each) do
      @file = EventImportFile.create :event_import => File.new("#{Rails.root.to_s}/examples/event_import_file_sample1.tsv")
    end

    it "should be imported" do
      closing_days_size = Event.closing_days.size
      old_events_count = Event.count
      old_import_results_count = EventImportResult.count
      @file.import_start.should eq({:imported => 3, :failed => 0})
      Event.count.should eq old_events_count + 3
      Event.closing_days.size.should eq closing_days_size + 1
      EventImportResult.count.should eq old_import_results_count + 4
    end
  end

  describe "When it is written in shift_jis" do
    before(:each) do
      @file = EventImportFile.create :event_import => File.new("#{Rails.root.to_s}/examples/event_import_file_sample2.tsv")
    end

    it "should be imported" do
      old_event_count = Event.count
      old_import_results_count = EventImportResult.count
      @file.import_start
      Event.order('id DESC').first.name.should eq '日本語の催し物2'
      Event.count.should eq old_event_count + 2
      EventImportResult.count.should eq old_import_results_count + 3
      Event.order('id DESC').first.start_at.should eq Time.zone.parse('2011-03-26').beginning_of_day
      Event.order('id DESC').first.end_at.to_s.should eq Time.zone.parse('2011-03-27').end_of_day.to_s
    end
  end
end

# == Schema Information
#
# Table name: event_import_files
#
#  id                        :integer         not null, primary key
#  parent_id                 :integer
#  content_type              :string(255)
#  size                      :integer
#  file_hash                 :string(255)
#  user_id                   :integer
#  note                      :text
#  imported_at               :datetime
#  state                     :string(255)
#  event_import_file_name    :string(255)
#  event_import_content_type :string(255)
#  event_import_file_size    :integer
#  event_import_updated_at   :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  edit_mode                 :string(255)
#

