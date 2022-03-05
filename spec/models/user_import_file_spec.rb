require 'rails_helper'

describe UserImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = UserImportFile.new user_import: fixture_file_upload("/user_import_file_sample.tsv")
      @file.default_user_group = UserGroup.find(2)
      @file.default_library = Library.find(3)
      @file.user = users(:admin)
      @file.save
    end

    it "should be imported" do
      file = UserImportFile.new user_import: fixture_file_upload("user_import_file_sample.tsv")
      file.default_user_group = UserGroup.find(2)
      file.default_library = Library.find(3)
      file.user = users(:admin)
      file.save
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      file.current_state.should eq 'pending'
      file.import_start.should eq({user_imported: 5, user_found: 0, failed: 0, error: 3})
      User.order('id DESC')[1].username.should eq 'user005'
      User.order('id DESC')[2].username.should eq 'user003'
      User.count.should eq old_users_count + 5

      user001 = User.find_by(username: 'user001')
      user001.profile.keyword_list.should eq "日本史\n地理"
      user001.profile.full_name.should eq '田辺 浩介'
      user001.profile.full_name_transcription.should eq 'たなべ こうすけ'
      user001.profile.required_role.name.should eq 'User'
      user001.locked_at.should be_truthy

      user002 = User.find_by(username: 'user002')
      user002.profile.user_group.name.should eq 'faculty'
      user002.profile.expired_at.to_i.should eq Time.zone.parse('2013-12-01').end_of_day.to_i
      user002.valid_password?('4NsxXPLy')
      user002.profile.user_number.should eq '001002'
      user002.profile.library.name.should eq 'hachioji'
      user002.profile.locale.should eq 'en'
      user002.profile.required_role.name.should eq 'Librarian'
      user002.locked_at.should be_nil

      user003 = User.find_by(username: 'user003')
      user003.profile.note.should eq 'テストユーザ'
      user003.role.name.should eq 'Librarian'
      user003.profile.user_number.should eq '001003'
      user003.profile.library.name.should eq 'kamata'
      user003.profile.locale.should eq 'ja'
      user003.profile.checkout_icalendar_token.should eq 'secrettoken'
      user003.profile.save_checkout_history.should be_truthy
      user003.profile.share_bookmarks.should be_falsy
      User.where(username: 'user000').first.should be_nil
      UserImportResult.count.should eq old_import_results_count + 10
      UserImportResult.order('id DESC')[0].error_message.should eq 'line 10: User number has already been taken'
      UserImportResult.order('id DESC')[1].error_message.should eq 'line 9: User number is invalid'
      UserImportResult.order('id DESC')[2].error_message.should eq 'line 8: Password is too short (minimum is 6 characters)'

      user005 = User.find_by(username: 'user005')
      user005.role.name.should eq 'User'
      user005.profile.library.name.should eq 'hachioji'
      user005.profile.locale.should eq 'en'
      user005.profile.user_number.should eq '001005'
      user005.profile.user_group.name.should eq 'faculty'

      user006 = User.find_by(username: 'user006')
      user006.role.name.should eq 'User'
      user006.profile.library.name.should eq 'hachioji'
      user006.profile.locale.should eq 'en'
      user006.profile.user_number.should be_nil
      user006.profile.user_group.name.should eq UserGroup.find(2).name

      file.user_import_fingerprint.should be_truthy
      file.executed_at.should be_truthy

      file.reload
      file.error_message.should eq "The following column(s) were ignored: save_search_history, invalid\nline 8: Password is too short (minimum is 6 characters)\nline 9: User number is invalid\nline 10: User number has already been taken"
      file.current_state.should eq 'failed'
    end

    it "should send message when import is completed" do
      old_message_count = Message.count
      @file.user = User.find_by(username: 'librarian1')
      @file.import_start
      Message.count.should eq old_message_count + 1
      Message.order(:created_at).last.subject.should eq "Import completed: #{@file.id}"
    end

    it "should not import users that have higher roles than current user's role" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.user = User.where(username: 'librarian1').first
      @file.import_start.should eq({user_imported: 4, user_found: 0, failed: 1, error: 3})
      User.order('id DESC')[1].username.should eq 'user005'
      User.count.should eq old_users_count + 4
      UserImportResult.count.should eq old_import_results_count + 10
    end
  end

  describe "when its mode is 'update'" do
    before(:each) do
      FactoryBot.create(:user,
        username: 'user001',
        profile: FactoryBot.create(:profile)
      )
    end

    it "should update users" do
      @file = UserImportFile.create!(
        user_import: fixture_file_upload("user_update_file.tsv"),
        user: users(:admin),
        default_library: libraries(:library_00001),
        default_user_group: user_groups(:user_group_00001)
      )
      old_message_count = Message.count
      result = @file.modify
      result.should have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      user001.email.should eq 'user001@example.jp'
      user001.profile.full_name.should eq '田辺 浩介'
      user001.profile.full_name_transcription.should eq 'たなべこうすけ'
      user001.profile.user_number.should eq 'user_number_1'
      user001.profile.note.should eq 'test'
      user001.profile.keyword_list.should eq 'keyword1 keyword2'
      Message.count.should eq old_message_count + 1
    end

    it "should not overwrite with null value" do
      user = User.where(username: 'user001').first
      user.profile = FactoryBot.create(:profile,
        user_number: '001',
        full_name: 'User 001',
        full_name_transcription: 'User 001',
        locale: 'ja',
        note: 'Note',
        keyword_list: 'keyword1 keyword2',
        date_of_birth: 10.years.ago)
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_update_file2.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      result.should have_key(:user_updated)
      user001 = User.friendly.find('user001')
      user001.email.should eq 'user001@example.jp'
      user001.profile.user_number.should eq '001'
      user001.profile.full_name.should eq 'User 001'
      user001.profile.full_name_transcription.should eq 'User 001'
      user001.profile.keyword_list.should eq 'keyword1 keyword2'
    end

    it "should update user_number" do
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_update_file3.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      result.should have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      user001.profile.user_number.should eq '0001'
    end

    it "should update user's lock status" do
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_update_file4.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      result.should have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      user001.access_locked?.should be_truthy
    end
  end

  describe "when its mode is 'destroy'" do
    before(:each) do
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_import_file_sample.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      file.import_start
    end

    it "should remove users" do
      old_count = User.count
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_delete_file.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      old_message_count = Message.count
      file.remove
      User.count.should eq old_count - 2
      Message.count.should eq old_message_count + 1
    end

    it "should not remove users if there are checkouts" do
      user001 = User.where(username: 'user001').first
      FactoryBot.create(:checkout, user: user001, item: FactoryBot.create(:item))
      old_count = User.count
      file = UserImportFile.create!(
        user_import: fixture_file_upload("user_delete_file.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      file.remove
      User.where(username: 'user001').should_not be_blank
      User.count.should eq old_count - 2
    end
  end

  it "should import in background" do
    file = UserImportFile.new user_import: fixture_file_upload("user_import_file_sample.tsv"), user: users(:admin)
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
#  user_import_file_name    :string
#  user_import_content_type :string
#  user_import_file_size    :integer
#  user_import_updated_at   :datetime
#  user_import_fingerprint  :string
#  edit_mode                :string
#  error_message            :text
#  created_at               :datetime
#  updated_at               :datetime
#  user_encoding            :string
#  default_library_id       :integer
#  default_user_group_id    :integer
#
