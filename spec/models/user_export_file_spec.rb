require 'rails_helper'
  
describe UserExportFile do
  fixtures :all
  
  it "should export users" do
    message_count = Message.count
    file = UserExportFile.create(user: users(:admin))
    file.export!
    #UserExportFileJob.perform_later(file).should be_truthy
    Message.count.should eq message_count + 1
    Message.order(:created_at).last.subject.should eq "Export completed: #{file.id}"
  end
end

# == Schema Information
#
# Table name: user_export_files
#
#  id          :bigint           not null, primary key
#  user_id     :bigint
#  executed_at :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
