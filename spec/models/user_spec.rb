require 'rails_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    FactoryBot.create(:user)
  end

  it 'should destroy an user' do
    user = FactoryBot.create(:user)
    user.destroy.should be_truthy
  end

  it 'should respond to has_role(Administrator)' do
    admin = FactoryBot.create(:admin)
    admin.has_role?('Administrator').should be_truthy
  end

  it 'should respond to has_role(Librarian)' do
    librarian = FactoryBot.create(:librarian)
    librarian.has_role?('Administrator').should be_falsy
    librarian.has_role?('Librarian').should be_truthy
    librarian.has_role?('User').should be_truthy
  end

  it 'should respond to has_role(User)' do
    user = FactoryBot.create(:user)
    user.has_role?('Administrator').should be_falsy
    user.has_role?('Librarian').should be_falsy
    user.has_role?('User').should be_truthy
  end

  it 'should lock an user' do
    user = FactoryBot.create(:user)
    user.locked = '1'
    user.save
    user.active_for_authentication?.should be_falsy
  end

  it 'should unlock an user' do
    user = FactoryBot.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    user.active_for_authentication?.should be_truthy
  end

  it "should create user" do
    user = FactoryBot.create(:user)
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
  end

  it "should require username" do
    old_count = User.count
    user = FactoryBot.build(:user, username: nil)
    user.save
    user.errors[:username].should be_truthy
    User.count.should eq old_count
  end

  it "should require password" do
    user = FactoryBot.build(:user, password: nil)
    user.save
    user.errors[:password].should be_truthy
  end

  it "should not require password_confirmation on create" do
    user = FactoryBot.build(:user, password: 'new_password', password_confirmation: nil)
    user.save
    user.errors[:email].should be_empty
  end

  it "should reset password" do
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    users(:user1).valid_password?('new password').should be_truthy
  end

  it "should set temporary_password" do
    user = users(:user1)
    old_password = user.encrypted_password
    user.set_auto_generated_password
    user.save
    old_password.should_not eq user.encrypted_password
    user.valid_password?('user1password').should be_falsy
  end

  it "should get highest_role" do
    users(:admin).role.name.should eq 'Administrator'
  end

  it "should lock all expired users" do
    User.lock_expired_users
    users(:user4).active_for_authentication?.should be_falsy
  end

  it "should lock_expired users" do
    user = users(:user1)
    users(:user1).active_for_authentication?.should be_truthy
    user.expired_at = 1.day.ago
    user.save
    users(:user1).active_for_authentication?.should be_falsy
  end

  if defined?(EnjuQuestion)
    it "should reset answer_feed_token" do
      users(:user1).reset_answer_feed_token
      users(:user1).answer_feed_token.should be_truthy
    end

    it "should delete answer_feed_token" do
      users(:user1).delete_answer_feed_token
      users(:user1).answer_feed_token.should be_nil
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

# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  username                  :string
#  expired_at                :datetime
#  failed_attempts           :integer          default(0)
#  unlock_token              :string
#  locked_at                 :datetime
#  confirmed_at              :datetime
#  encrypted_otp_secret      :string
#  encrypted_otp_secret_iv   :string
#  encrypted_otp_secret_salt :string
#  consumed_timestep         :integer
#  otp_required_for_login    :boolean          default(FALSE), not null
#  otp_backup_codes          :string           is an Array
#

