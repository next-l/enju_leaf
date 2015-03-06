# -*- encoding: utf-8 -*-
require 'spec_helper'
  
describe UserExportFile do
  fixtures :all
  
  it "should export in background" do
    message_count = Message.count
    file = UserExportFile.new
    file.user = users(:admin)
    file.save
    UserExportFileJob.perform_later(file).should be_truthy
  end

  it "should send message" do
    message_count = Message.count
    file = UserExportFile.new
    file.user = users(:admin)
    file.save
    file.export!
    Message.count.should eq message_count + 1
    Message.order(:id).last.subject.should eq 'エクスポートが完了しました'
  end
end

# == Schema Information
#
# Table name: user_export_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  executed_at              :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  user_export_id           :string
#  user_export_file_name    :string
#  user_export_size         :integer
#  user_export_content_type :string
#
