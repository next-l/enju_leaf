require 'rails_helper'

describe EventExportFile do
  fixtures :all

  it "should export in background" do
    message_count = Message.count
    file = EventExportFile.new
    file.user = users(:admin)
    file.save
    expect(EventExportFileJob.perform_later(file)).to be_truthy
    # Message.count.should eq message_count + 1
    # Message.order(:created_at).last.subject.should eq "Export completed: #{file.id}"
  end
end

# == Schema Information
#
# Table name: event_export_files
#
#  id                        :bigint           not null, primary key
#  user_id                   :bigint
#  event_export_file_name    :string
#  event_export_content_type :string
#  event_export_file_size    :bigint
#  event_export_updated_at   :datetime
#  executed_at               :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
