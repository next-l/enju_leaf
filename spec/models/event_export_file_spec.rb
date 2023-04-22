require 'rails_helper'
 
describe EventExportFile do
  fixtures :all
  
  it "should export events" do
    export_file = EventExportFile.create!(user: users(:admin))
    export_file.export!
    expect(export_file.event_export_file_name).to eq 'event_export.txt'
  end
end

# == Schema Information
#
# Table name: event_export_files
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  event_export_file_name    :string
#  event_export_content_type :string
#  event_export_file_size    :bigint
#  event_export_updated_at   :datetime
#  executed_at               :datetime
#  created_at                :datetime
#  updated_at                :datetime
#
