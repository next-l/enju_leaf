require 'rails_helper'

describe User do
  # pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    FactoryBot.create(:user)
  end

  it 'should destroy an user' do
    user = FactoryBot.create(:user)
    expect(user.destroy).to be_truthy
  end

  it 'should respond to has_role(Administrator)' do
    admin = FactoryBot.create(:admin)
    expect(admin.has_role?('Administrator')).to be_truthy
  end

  it 'should respond to has_role(Librarian)' do
    librarian = FactoryBot.create(:librarian)
    expect(librarian.has_role?('Administrator')).to be_falsy
    expect(librarian.has_role?('Librarian')).to be_truthy
    expect(librarian.has_role?('User')).to be_truthy
  end

  it 'should respond to has_role(User)' do
    user = FactoryBot.create(:user)
    expect(user.has_role?('Administrator')).to be_falsy
    expect(user.has_role?('Librarian')).to be_falsy
    expect(user.has_role?('User')).to be_truthy
  end

  it 'should lock an user' do
    user = FactoryBot.create(:user)
    user.locked = '1'
    user.save
    expect(user.active_for_authentication?).to be_falsy
  end

  it 'should unlock an user' do
    user = FactoryBot.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    expect(user.active_for_authentication?).to be_truthy
  end

  it "should create user" do
    user = FactoryBot.create(:user)
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
  end

  it "should require username" do
    old_count = User.count
    user = FactoryBot.build(:user, username: nil)
    user.save
    expect(user.errors[:username]).to be_truthy
    expect(User.count).to eq old_count
  end

  it "should require password" do
    user = FactoryBot.build(:user, password: nil)
    user.save
    expect(user.errors[:password]).to be_truthy
  end

  it "should not require password_confirmation on create" do
    user = FactoryBot.build(:user, password: 'new_password', password_confirmation: nil)
    user.save
    expect(user.errors[:email]).to be_empty
  end

  it "should reset password" do
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    expect(users(:user1).valid_password?('new password')).to be_truthy
  end

  it "should set temporary_password" do
    user = users(:user1)
    old_password = user.encrypted_password
    user.set_auto_generated_password
    user.save
    expect(old_password).not_to eq user.encrypted_password
    expect(user.valid_password?('user1password')).to be_falsy
  end

  it "should get highest_role" do
    expect(users(:admin).role.name).to eq 'Administrator'
  end

  it "should lock all expired users" do
    User.lock_expired_users
    expect(users(:user4).active_for_authentication?).to be_falsy
  end

  it "should lock_expired users" do
    user = users(:user1)
    expect(users(:user1).active_for_authentication?).to be_truthy
    user.expired_at = 1.day.ago
    user.save
    expect(users(:user1).active_for_authentication?).to be_falsy
  end

  if defined?(EnjuQuestion)
    it "should reset answer_feed_token" do
      users(:user1).reset_answer_feed_token
      expect(users(:user1).answer_feed_token).to be_truthy
    end

    it "should delete answer_feed_token" do
      users(:user1).delete_answer_feed_token
      expect(users(:user1).answer_feed_token).to be_nil
    end
  end

  describe ".export" do
    it "should export all user's information" do
      lines = User.export
      CSV.parse(lines, col_sep: "\t")
      expect(lines).not_to be_empty
      expect(lines.split(/\n/).size).to eq User.count + 1
    end
  end
end

# ## Schema Information
#
# Table name: `users`
#
# ### Columns
#
# Name                          | Type               | Attributes
# ----------------------------- | ------------------ | ---------------------------
# **`id`**                      | `bigint`           | `not null, primary key`
# **`confirmed_at`**            | `datetime`         |
# **`email`**                   | `string`           | `default(""), not null`
# **`encrypted_password`**      | `string`           | `default(""), not null`
# **`expired_at`**              | `datetime`         |
# **`failed_attempts`**         | `integer`          | `default(0)`
# **`locked_at`**               | `datetime`         |
# **`remember_created_at`**     | `datetime`         |
# **`reset_password_sent_at`**  | `datetime`         |
# **`reset_password_token`**    | `string`           |
# **`unlock_token`**            | `string`           |
# **`username`**                | `string`           | `not null`
# **`created_at`**              | `datetime`         | `not null`
# **`updated_at`**              | `datetime`         | `not null`
# **`profile_id`**              | `bigint`           | `not null`
#
# ### Indexes
#
# * `index_users_on_email`:
#     * **`email`**
# * `index_users_on_profile_id` (_unique_):
#     * **`profile_id`**
# * `index_users_on_reset_password_token` (_unique_):
#     * **`reset_password_token`**
# * `index_users_on_unlock_token` (_unique_):
#     * **`unlock_token`**
# * `index_users_on_username` (_unique_):
#     * **`username`**
#
# ### Foreign Keys
#
# * `fk_rails_...`:
#     * **`profile_id => profiles.id`**
#
