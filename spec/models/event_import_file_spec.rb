require 'rails_helper'

describe EventImportFile do
  fixtures :all
  #pending "add some examples to (or delete) #{__FILE__}"

  describe "When it is written in utf-8" do
    before(:each) do
      @file = EventImportFile.create!(
        default_library_id: 3,
        default_event_category: EventCategory.find(3),
        user: users(:admin)
      )
      @file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/event_import_file_sample1.tsv"), filename: 'attachment.txt')
    end

    it "should be imported" do
      closing_days_size = Event.closing_days.size
      old_events_count = Event.count
      old_import_results_count = EventImportResult.count
      expect(@file.import_start).to eq({ imported: 2, failed: 2 })
      expect(Event.count).to eq old_events_count + 2
      expect(Event.closing_days.size).to eq closing_days_size + 1
      expect(EventImportResult.count).to eq old_import_results_count + 5
      expect(Event.order(:id).last.library.name).to eq 'hachioji'
      expect(Event.order(:id).last.name).to eq 'event3'
      expect(Event.where(name: 'event2').first).to be_nil
      event3 = Event.where(name: 'event3').first
      expect(event3.display_name).to eq 'イベント3'
      expect(event3.event_category.name).to eq 'book_talk'
      event4 = Event.where(name: '休館日1').first
      expect(event4.event_category.name).to eq 'closed'

      # @file.event_import_fingerprint.should be_truthy
      expect(@file.executed_at).to be_truthy

      @file.reload
      expect(@file.error_message).to eq "The following column(s) were ignored: invalid"
    end

    it "should send message when import is completed" do
      old_message_count = Message.count
      @file.user = User.find_by(username: 'librarian1')
      @file.import_start
      expect(Message.count).to eq old_message_count + 1
      expect(Message.order(:created_at).last.subject).to eq "Import completed: #{@file.id}"
    end
  end

  describe "When it is written in shift_jis" do
    before(:each) do
      @file = EventImportFile.create!(
        default_library: Library.find(3),
        default_event_category: EventCategory.find(3),
        user: users(:admin)
      )
      @file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/event_import_file_sample2.tsv"), filename: 'attachment.txt')
    end

    it "should be imported" do
      old_event_count = Event.count
      old_import_results_count = EventImportResult.count
      @file.import_start
      Event.order('id DESC').first.name.should eq 'event3'
      Event.count.should eq old_event_count + 2
      EventImportResult.count.should eq old_import_results_count + 5
      Event.order('id DESC').first.start_at.should eq Time.zone.parse('2014-07-01').beginning_of_day
      Event.order('id DESC').first.end_at.should eq Time.zone.parse('2014-07-31 14:00')
    end
  end

  describe "When it is an invalid file" do
    before(:each) do
      @file = EventImportFile.create!(
        user: users(:admin)
      )
      @file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/invalid_file.tsv"), filename: 'attachment.txt')
    end

    it "should not be imported" do
      old_event_count = Event.count
      old_import_results_count = EventImportResult.count
      lambda {@file.import_start}.should raise_error(RuntimeError)
      Event.count.should eq Event.count
      EventImportResult.count.should eq EventImportResult.count
    end
  end

  describe "when its mode is 'update'" do
    it "should update events" do
      file = EventImportFile.create!(
        user: users(:admin)
      )
      file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/event_update_file.tsv"), filename: 'attachment.txt')
      file.modify
      event1 = Event.find(1)
      event1.name.should eq '変更後のイベント名'
      event1.start_at.should eq Time.zone.parse('2012-04-01').beginning_of_day
      event1.end_at.should eq Time.zone.parse('2012-04-02')

      event2 = Event.find(2)
      event2.end_at.should eq Time.zone.parse('2012-04-03')
      event2.all_day.should be_falsy
      event2.library.name.should eq 'mita'

      event3 = Event.find(3)
      event3.name.should eq 'ミーティング'
    end
  end


  describe "when its mode is 'destroy'" do
    it "should destroy events" do
      old_event_count = Event.count
      file = EventImportFile.create!(
        user: users(:admin)
      )
      file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/event_destroy_file.tsv"), filename: 'attachment.txt')
      file.remove
      Event.count.should eq old_event_count - 2
    end
  end

  it "should import in background" do
    file = EventImportFile.create!(
      user: users(:admin)
    )
    file.attachment.attach(io: File.new("#{Rails.root}/spec/fixtures/files/event_import_file_sample1.tsv"), filename: 'attachment.txt')
    EventImportFileJob.perform_later(file).should be_truthy
  end
end

# == Schema Information
#
# Table name: event_import_files
#
#  id                        :bigint           not null, primary key
#  edit_mode                 :string
#  error_message             :text
#  event_import_fingerprint  :string
#  executed_at               :datetime
#  note                      :text
#  user_encoding             :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  default_event_category_id :bigint
#  default_library_id        :bigint
#  parent_id                 :bigint
#  user_id                   :bigint           not null
#
# Indexes
#
#  index_event_import_files_on_parent_id  (parent_id)
#  index_event_import_files_on_user_id    (user_id)
#
