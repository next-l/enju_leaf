# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = UserImportFile.create! :user_import => File.new("#{Rails.root.to_s}/../../examples/user_import_file_sample1.tsv")
    end

    it "should be imported" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.state.should eq 'pending'
      @file.import_start.should eq({:user_imported => 3, :user_imported => 0, :failed => 0})
      User.order('id DESC')[0].full_name.should eq '原田 ushi 隆史'
      User.order('id DESC')[1].full_name.should eq '田辺浩介'
      User.order('id DESC')[2].date_of_birth.should eq Time.zone.parse('1978-01-01')
      User.count.should eq old_users_count + 3
      UserImportResult.count.should eq old_import_results_count + 4

      @file.user_import_fingerprint.should be_true
      @file.executed_at.should be_true
    end
  end

  describe "when it is written in shift_jis" do
    before(:each) do
      @file = UserImportFile.create! :user_import => File.new("#{Rails.root.to_s}/../../examples/user_import_file_sample3.tsv")
    end

    it "should be imported" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.state.should eq 'pending'
      @file.import_start.should eq({:user_imported => 4, :user_imported => 0, :failed => 0})
      User.count.should eq old_users_count + 4
      User.order('id DESC')[0].full_name.should eq '原田 ushi 隆史'
      User.order('id DESC')[1].full_name.should eq '田辺浩介'
      User.order('id DESC')[2].email.should eq 'fugafuga@example.jp'
      User.order('id DESC')[3].required_role.should eq Role.find_by_name('Guest')
      User.order('id DESC')[1].email.should eq 'tanabe@library.example.jp'
      UserImportResult.count.should eq old_import_results_count + 5

      @file.user_import_fingerprint.should be_true
      @file.executed_at.should be_true
    end
  end

  describe "when its mode is 'update'" do
    it "should update users" do
      @file = UserImportFile.create :user_import => File.new("#{Rails.root.to_s}/../../examples/user_update_file.tsv")
      @file.modify
      user_1 = User.find(1)
      user_1.full_name.should eq 'たなべこうすけ'
      user_1.address_1.should eq '東京都'
      user_2 = User.find(2)
      user_2.full_name.should eq '田辺浩介'
      user_2.address_1.should eq '岡山県'
    end
  end

  describe "when its mode is 'destroy'" do
    it "should remove users" do
      old_count = User.count
      @file = UserImportFile.create :user_import => File.new("#{Rails.root.to_s}/../../examples/user_delete_file.tsv")
      @file.remove
      User.count.should eq old_count - 7
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

