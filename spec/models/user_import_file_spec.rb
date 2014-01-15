# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = UserImportFile.new :user_import => File.new("#{Rails.root.to_s}/../../examples/user_import_file_sample.tsv")
      @file.user = users(:admin)
      @file.save
    end

    it "should be imported" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.state.should eq 'pending'
      @file.import_start.should eq({:user_imported => 3, :user_found => 0, :failed => 0})
      User.order('id DESC')[1].username.should eq 'user002'
      User.order('id DESC')[2].username.should eq 'user001'
      User.count.should eq old_users_count + 3
      user = User.where(:username => 'user003').first
      user.note.should eq 'テストユーザ'
      user.role.name.should eq 'Librarian'
      UserImportResult.count.should eq old_import_results_count + 4

      @file.user_import_fingerprint.should be_true
      @file.executed_at.should be_true
    end
  end

  describe "when its mode is 'update'" do
    it "should update users" do
      @file = UserImportFile.create :user_import => File.new("#{Rails.root.to_s}/../../examples/user_update_file.tsv")
      @file.modify
    end
  end

  describe "when its mode is 'destroy'" do
    before(:each) do
      @file = UserImportFile.new :user_import => File.new("#{Rails.root.to_s}/../../examples/user_import_file_sample.tsv")
      @file.user = users(:admin)
      @file.save
      @file.import_start
    end

    it "should remove users" do
      old_count = User.count
      @file = UserImportFile.create :user_import => File.new("#{Rails.root.to_s}/../../examples/user_delete_file.tsv")
      @file.remove
      User.count.should eq old_count - 3
    end
  end
end

# == Schema Information
#
# Table name: user_import_files
#
#  id                        :integer          not null, primary key
#  parent_id                 :integer
#  content_type              :string(255)
#  size                      :integer
#  user_id                   :integer
#  note                      :text
#  executed_at               :datetime
#  state                     :string(255)
#  user_import_file_name    :string(255)
#  user_import_content_type :string(255)
#  user_import_file_size    :integer
#  user_import_updated_at   :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  user_import_fingerprint  :string(255)
#  error_message             :text
#  edit_mode                 :string(255)
#

