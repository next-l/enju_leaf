require 'rails_helper'

describe UserImportFile do
  fixtures :all

  describe "when its mode is 'create'" do
    before(:each) do
      @file = UserImportFile.new attachment: fixture_file_upload("/user_import_file_sample.tsv")
      @file.default_user_group = UserGroup.find(2)
      @file.default_library = Library.find(3)
      @file.user = users(:admin)
      @file.save
    end

    it "should be imported" do
      file = UserImportFile.new attachment: fixture_file_upload("user_import_file_sample.tsv")
      file.default_user_group = UserGroup.find(2)
      file.default_library = Library.find(3)
      file.user = users(:admin)
      file.save
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      expect(file.current_state).to eq 'pending'
      expect(file.import_start).to eq({ user_imported: 5, user_found: 0, failed: 0, error: 3 })
      expect(User.order('id DESC')[1].username).to eq 'user005'
      expect(User.order('id DESC')[2].username).to eq 'user003'
      expect(User.count).to eq old_users_count + 5

      user001 = User.find_by(username: 'user001')
      expect(user001.profile.keyword_list).to eq "日本史\n地理"
      expect(user001.profile.full_name).to eq '田辺 浩介'
      expect(user001.profile.full_name_transcription).to eq 'たなべ こうすけ'
      expect(user001.profile.required_role.name).to eq 'User'
      expect(user001.locked_at).to be_truthy

      user002 = User.find_by(username: 'user002')
      expect(user002.profile.user_group.name).to eq 'faculty'
      expect(user002.profile.expired_at.to_i).to eq Time.zone.parse('2013-12-01').end_of_day.to_i
      user002.valid_password?('4NsxXPLy')
      expect(user002.profile.user_number).to eq '001002'
      expect(user002.profile.library.name).to eq 'hachioji'
      expect(user002.profile.locale).to eq 'en'
      expect(user002.profile.required_role.name).to eq 'Librarian'
      expect(user002.locked_at).to be_nil

      user003 = User.find_by(username: 'user003')
      expect(user003.profile.note).to eq 'テストユーザ'
      expect(user003.role.name).to eq 'Librarian'
      expect(user003.profile.user_number).to eq '001003'
      expect(user003.profile.library.name).to eq 'kamata'
      expect(user003.profile.locale).to eq 'ja'
      expect(user003.profile.checkout_icalendar_token).to eq 'secrettoken'
      expect(user003.profile.save_checkout_history).to be_truthy
      expect(user003.profile.share_bookmarks).to be_falsy
      expect(User.where(username: 'user000').first).to be_nil
      expect(UserImportResult.count).to eq old_import_results_count + 10
      expect(UserImportResult.order('id DESC')[0].error_message).to eq 'line 10: User number has already been taken'
      expect(UserImportResult.order('id DESC')[1].error_message).to eq 'line 9: User number is invalid'
      expect(UserImportResult.order('id DESC')[2].error_message).to eq 'line 8: Password is too short (minimum is 6 characters)'

      user005 = User.find_by(username: 'user005')
      expect(user005.role.name).to eq 'User'
      expect(user005.profile.library.name).to eq 'hachioji'
      expect(user005.profile.locale).to eq 'en'
      expect(user005.profile.user_number).to eq '001005'
      expect(user005.profile.user_group.name).to eq 'faculty'

      user006 = User.find_by(username: 'user006')
      expect(user006.role.name).to eq 'User'
      expect(user006.profile.library.name).to eq 'hachioji'
      expect(user006.profile.locale).to eq 'en'
      expect(user006.profile.user_number).to be_nil
      expect(user006.profile.user_group.name).to eq UserGroup.find(2).name

      expect(file.executed_at).to be_truthy

      file.reload
      expect(file.error_message).to eq "The following column(s) were ignored: save_search_history, invalid\nline 8: Password is too short (minimum is 6 characters)\nline 9: User number is invalid\nline 10: User number has already been taken"
      expect(file.current_state).to eq 'failed'
    end

    it "should send message when import is completed" do
      old_message_count = Message.count
      @file.user = User.find_by(username: 'librarian1')
      @file.import_start
      expect(Message.count).to eq old_message_count + 1
      expect(Message.order(:created_at).last.subject).to eq "Import completed: #{@file.id}"
    end

    it "should not import users that have higher roles than current user's role" do
      old_users_count = User.count
      old_import_results_count = UserImportResult.count
      @file.user = User.where(username: 'librarian1').first
      expect(@file.import_start).to eq({ user_imported: 4, user_found: 0, failed: 1, error: 3 })
      expect(User.order('id DESC')[1].username).to eq 'user005'
      expect(User.count).to eq old_users_count + 4
      expect(UserImportResult.count).to eq old_import_results_count + 10
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
        attachment: fixture_file_upload("user_update_file.tsv"),
        user: users(:admin),
        default_library: libraries(:library_00001),
        default_user_group: user_groups(:user_group_00001)
      )
      old_message_count = Message.count
      result = @file.modify
      expect(result).to have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      expect(user001.email).to eq 'user001@example.jp'
      expect(user001.profile.full_name).to eq '田辺 浩介'
      expect(user001.profile.full_name_transcription).to eq 'たなべこうすけ'
      expect(user001.profile.user_number).to eq 'user_number_1'
      expect(user001.profile.note).to eq 'test'
      expect(user001.profile.keyword_list).to eq 'keyword1 keyword2'
      expect(Message.count).to eq old_message_count + 1
    end

    it "should not overwrite with null value" do
      user = User.where(username: 'user001').first
      user.profile.update!(
        user_number: '001',
        full_name: 'User 001',
        full_name_transcription: 'User 001',
        locale: 'ja',
        note: 'Note',
        keyword_list: 'keyword1 keyword2',
        date_of_birth: 10.years.ago
      )
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_update_file2.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      expect(result).to have_key(:user_updated)
      user001 = User.friendly.find('user001')
      expect(user001.email).to eq 'user001@example.jp'
      expect(user001.profile.user_number).to eq '001'
      expect(user001.profile.full_name).to eq 'User 001'
      expect(user001.profile.full_name_transcription).to eq 'User 001'
      expect(user001.profile.keyword_list).to eq 'keyword1 keyword2'
    end

    it "should update user_number" do
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_update_file3.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      expect(result).to have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      expect(user001.profile.user_number).to eq '0001'
    end

    it "should update user's lock status" do
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_update_file4.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      expect(result).to have_key(:user_updated)
      user001 = User.where(username: 'user001').first
      expect(user001.access_locked?).to be_truthy
    end

    it "should update user's password" do
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_update_file4.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      result = file.modify
      expect(result).to have_key(:user_updated)
      user001 = User.find_by(username: 'user001')
      expect(user001.access_locked?).to be_truthy
      expect(user001.valid_password?('testpassword')).to be_truthy
      user002 = User.find_by(username: 'librarian1')
      expect(user002.valid_password?('librarian1password')).to be_truthy
    end
  end

  describe "when its mode is 'destroy'" do
    before(:each) do
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_import_file_sample.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      file.import_start
    end

    it "should remove users" do
      old_count = User.count
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_delete_file.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      old_message_count = Message.count
      file.remove
      expect(User.count).to eq old_count - 2
      expect(Message.count).to eq old_message_count + 1
    end

    it "should not remove users if there are checkouts" do
      user001 = User.where(username: 'user001').first
      FactoryBot.create(:checkout, user: user001, item: FactoryBot.create(:item))
      old_count = User.count
      file = UserImportFile.create!(
        attachment: fixture_file_upload("user_delete_file.tsv"),
        user: users(:admin),
        default_user_group: UserGroup.find(2),
        default_library: Library.find(3)
      )
      file.remove
      expect(User.where(username: 'user001')).not_to be_blank
      expect(User.count).to eq old_count - 2
    end
  end

  it "should import in background" do
    file = UserImportFile.new attachment: fixture_file_upload("user_import_file_sample.tsv"), user: users(:admin)
    file.user = users(:admin)
    file.default_user_group = UserGroup.find(2)
    file.default_library = Library.find(3)
    file.save
    expect(UserImportFileJob.perform_later(file)).to be_truthy
  end
end

# ## Schema Information
#
# Table name: `user_import_files`
#
# ### Columns
#
# Name                           | Type               | Attributes
# ------------------------------ | ------------------ | ---------------------------
# **`id`**                       | `bigint`           | `not null, primary key`
# **`edit_mode`**                | `string`           |
# **`error_message`**            | `text`             |
# **`executed_at`**              | `datetime`         |
# **`note`**                     | `text`             |
# **`user_encoding`**            | `string`           |
# **`user_import_fingerprint`**  | `string`           |
# **`created_at`**               | `datetime`         | `not null`
# **`updated_at`**               | `datetime`         | `not null`
# **`default_library_id`**       | `bigint`           |
# **`default_user_group_id`**    | `bigint`           |
# **`user_id`**                  | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_user_import_files_on_user_id`:
#     * **`user_id`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`user_id => users.id`**
#
