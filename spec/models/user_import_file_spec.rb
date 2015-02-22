# -*- encoding: utf-8 -*-
require 'spec_helper'

describe UserImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = UserImportFile.new :user_import => File.new("#{Rails.root}/../../examples/user_import_file_sample.tsv")
      @file.default_user_group = UserGroup.find(2)
      @file.default_library = Library.find(3)
      @file.user = users(:admin)
      @file.save
    end

    it "should be imported", solr: true do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      old_profiles_solr_count = Profile.search.total
      @file.current_state.should eq 'pending'
      @file.import_start.should eq({:user_imported => 5, :user_found => 0, :failed => 0})
      User.order('id DESC')[1].username.should eq 'user005'
      User.order('id DESC')[2].username.should eq 'user003'
      User.count.should eq old_users_count + 5
      Profile.search.total.should eq old_profiles_solr_count + 5

      user001 = User.where(username: 'user001').first
      user001.profile.keyword_list.should eq "日本史\n地理"
      user001.profile.full_name.should eq '田辺 浩介'
      user001.profile.full_name_transcription.should eq 'たなべ こうすけ'
      user001.profile.required_role.name.should eq 'User'
      user001.locked_at.should be_truthy

      user002 = User.where(username: 'user002').first
      user002.profile.user_group.name.should eq 'faculty'
      user002.profile.expired_at.to_i.should eq Time.zone.parse('2013-12-01').end_of_day.to_i
      user002.valid_password?('4NsxXPLy')
      user002.profile.user_number.should eq '001002'
      user002.profile.library.name.should eq 'hachioji'
      user002.profile.locale.should eq 'en'
      user002.profile.required_role.name.should eq 'Librarian'
      user002.locked_at.should be_nil

      user003 = User.where(username: 'user003').first
      user003.profile.note.should eq 'テストユーザ'
      user003.role.name.should eq 'Librarian'
      user003.profile.user_number.should eq '001003'
      user003.profile.library.name.should eq 'kamata'
      user003.profile.locale.should eq 'ja'
      user003.profile.checkout_icalendar_token.should eq 'secrettoken'
      user003.profile.save_checkout_history.should be_truthy
      user003.profile.save_search_history.should be_falsy
      user003.profile.share_bookmarks.should be_falsy
      User.where(username: 'user000').first.should be_nil
      UserImportResult.count.should eq old_import_results_count + 6

      user005 = User.where(username: 'user005').first
      user005.role.name.should eq 'User'
      user005.profile.library.name.should eq 'hachioji'
      user005.profile.locale.should eq 'en'
      user005.profile.user_number.should eq '001005'
      user005.profile.user_group.name.should eq 'faculty'

      user006 = User.where(username: 'user006').first
      user006.role.name.should eq 'User'
      user006.profile.library.name.should eq 'hachioji'
      user006.profile.locale.should eq 'en'
      user006.profile.user_number.should be_nil
      user006.profile.user_group.name.should eq UserGroup.find(2).name

      @file.user_import_fingerprint.should be_truthy
      @file.executed_at.should be_truthy

      @file.reload
      @file.error_message.should eq "The follwing column(s) were ignored: invalid"
    end

    it "should send message when import is completed" do
      old_message_count = Message.count
      @file.user = User.where(username: 'librarian1').first
      @file.import_start
      Message.count.should eq old_message_count + 1
      Message.order(:id).last.subject.should eq 'インポートが完了しました'
    end

    it "should not import users that have higher roles than current user's role" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.user = User.where(username: 'librarian1').first
      @file.import_start.should eq({:user_imported => 4, :user_found => 0, :failed => 1})
      User.order('id DESC')[1].username.should eq 'user005'
      User.count.should eq old_users_count + 4
    end
  end

  describe "when its mode is 'update'" do
    it "should update users" do
      @file = UserImportFile.create :user_import => File.new("#{Rails.root}/../../examples/user_update_file.tsv")
      @file.modify
    end
  end

  describe "when its mode is 'destroy'" do
    before(:each) do
      @file = UserImportFile.new :user_import => File.new("#{Rails.root}/../../examples/user_import_file_sample.tsv")
      @file.user = users(:admin)
      @file.default_user_group = UserGroup.find(2)
      @file.default_library = Library.find(3)
      @file.save
      @file.import_start
    end

    it "should remove users" do
      old_count = User.count
      @file = UserImportFile.create :user_import => File.new("#{Rails.root}/../../examples/user_delete_file.tsv")
      @file.remove
      User.count.should eq old_count - 3
    end
  end

  it "should import in background" do
    file = UserImportFile.new :user_import => File.new("#{Rails.root}/../../examples/user_import_file_sample.tsv")
    file.user = users(:admin)
    file.default_user_group = UserGroup.find(2)
    file.default_library = Library.find(3)
    file.save
    UserImportFileJob.perform_later(file).should be_truthy
  end
end

# == Schema Information
#
# Table name: user_import_files
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  note                     :text
#  executed_at              :datetime
#  user_import_file_name    :string(255)
#  user_import_content_type :string(255)
#  user_import_file_size    :string(255)
#  user_import_updated_at   :datetime
#  user_import_fingerprint  :string(255)
#  edit_mode                :string(255)
#  error_message            :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  user_encoding            :string(255)
#  default_library_id       :integer
#  default_user_group_id    :integer
#
