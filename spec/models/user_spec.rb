# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    FactoryGirl.create(:user)
  end

  it 'should destroy an user' do
    user = FactoryGirl.create(:user)
    user.destroy.should be_truthy
  end

  it 'should respond to has_role(Administrator)' do
    admin = FactoryGirl.create(:admin)
    admin.has_role?('Administrator').should be_truthy
  end

  it 'should respond to has_role(Librarian)' do
    librarian = FactoryGirl.create(:librarian)
    librarian.has_role?('Administrator').should be_falsy
    librarian.has_role?('Librarian').should be_truthy
    librarian.has_role?('User').should be_truthy
  end

  it 'should respond to has_role(User)' do
    user = FactoryGirl.create(:user)
    user.has_role?('Administrator').should be_falsy
    user.has_role?('Librarian').should be_falsy
    user.has_role?('User').should be_truthy
  end

  it 'should lock an user' do
    user = FactoryGirl.create(:user)
    user.locked = '1'
    user.save
    user.active_for_authentication?.should be_falsy
  end

  it 'should unlock an user' do
    user = FactoryGirl.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    user.active_for_authentication?.should be_truthy
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = FactoryGirl.create(:user)
    user.expired_at.should be_nil
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = FactoryGirl.build(:user)
    user.user_group = FactoryGirl.create(:user_group, :valid_period_for_new_user => 10)
    user.save
    user.expired_at.should eq 10.days.from_now.end_of_day
  end

  it "should create user" do
    user = FactoryGirl.create(:user)
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
  end

  it "should require username" do
    old_count = User.count
    user = FactoryGirl.build(:user, :username => nil)
    user.save
    user.errors[:username].should be_truthy
    User.count.should eq old_count
  end

  it "should not require user_number" do
    user = FactoryGirl.create(:user, :user_number => nil)
    user.errors[:user_number].should be_empty
  end

  it "should require password" do
    user = FactoryGirl.build(:user, :password => nil)
    user.save
    user.errors[:password].should be_truthy
  end

  it "should not require password_confirmation on create" do
    user = FactoryGirl.build(:user, :password => 'new_password', :password_confirmation => nil)
    user.save
    user.errors[:email].should be_empty
  end

  it "should not require email on create if an operator is set" do
    user = FactoryGirl.build(:user, :email => '')
    user.operator = FactoryGirl.create(:admin)
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

  if defined?(EnjuCirculation)
    it "should reset checkout_icalendar_token" do
      users(:user1).reset_checkout_icalendar_token
      users(:user1).checkout_icalendar_token.should be_truthy
    end

    it "should delete checkout_icalendar_token" do
      users(:user1).delete_checkout_icalendar_token
      users(:user1).checkout_icalendar_token.should be_nil
    end

    it "should get checked_item_count" do
      count = users(:user1).checked_item_count
      count.should eq({:book=>2, :serial=>1, :cd=>0})
    end

    it "should get reserves_count" do
      users(:user1).reserves.waiting.count.should eq 1
    end
  end

  if defined?(EnjuMessage)
    it "should send_message" do
      assert users(:librarian1).send_message('reservation_expired_for_patron', :manifestations => users(:librarian1).reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
      users(:librarian1).reload
      users(:librarian1).reserves.not_sent_expiration_notice_to_patron.should be_empty
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  username               :string(255)
#  user_number            :string(255)
#  state                  :string(255)
#  locale                 :string(255)
#  deleted_at             :datetime
#  expired_at             :datetime
#  library_id             :integer          default(1), not null
#  required_role_id       :integer          default(1), not null
#  user_group_id          :integer          default(1), not null
#  note                   :text
#  keyword_list           :text
#  failed_attempts        :integer          default(0)
#  unlock_token           :string(255)
#  locked_at              :datetime
#  confirmed_at           :datetime
#
