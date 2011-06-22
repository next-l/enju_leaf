# -*- encoding: utf-8 -*-
require 'spec_helper'

describe User do
  #pending "add some examples to (or delete) #{__FILE__}"
  fixtures :all

  it 'should create an user' do
    Factory.create(:user)
  end

  it 'should destroy an user' do
    user = Factory.create(:user)
    user.destroy.should be_true
  end

  it 'should respond to has_role(Administrator)' do
    admin = Factory.create(:admin)
    admin.has_role?('Administrator').should be_true
  end

  it 'should respond to has_role(Librarian)' do
    librarian = Factory.create(:librarian)
    librarian.has_role?('Administrator').should be_false
    librarian.has_role?('Librarian').should be_true
    librarian.has_role?('User').should be_true
  end

  it 'should respond to has_role(User)' do
    user = Factory.create(:user)
    user.has_role?('Administrator').should be_false
    user.has_role?('Librarian').should be_false
    user.has_role?('User').should be_true
  end

  it 'should lock an user' do
    user = Factory.create(:user)
    user.locked = '1'
    user.save
    user.active_for_authentication?.should be_false
  end

  it 'should unlock an user' do
    user = Factory.create(:user)
    user.lock_access!
    user.locked = '0'
    user.save
    user.active_for_authentication?.should be_true
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = Factory.create(:user)
    user.expired_at.should be_nil
  end

  it 'should not set expired_at if its user group does not have valid period' do
    user = Factory.build(:user)
    user.user_group = Factory.create(:user_group, :valid_period_for_new_user => 10)
    user.save
    user.expired_at.should eq 10.days.from_now.end_of_day
  end

  it "should create user" do
    user = Factory.create(:user)
    assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
  end

  it "should require username" do
    old_count = User.count
    user = Factory.build(:user, :username => nil)
    user.save
    user.errors[:username].should be_true
    User.count.should eq old_count
  end

  it "should not require user_number" do
    user = Factory.create(:user, :user_number => nil)
    user.errors[:user_number].should be_empty
  end

  it "should require password" do
    user = Factory.build(:user, :password => nil)
    user.save
    user.errors[:password].should be_true
  end

  it "should not require password_confirmation on create" do
    user = Factory.build(:user, :password => 'new_password', :password_confirmation => nil)
    user.save
    user.errors[:email].should be_empty
  end

  it "should not require email on create if an operator is set" do
    user = Factory.build(:user, :email => '')
    user.operator = Factory.create(:admin)
    user.save
    user.errors[:email].should be_empty
  end

  it "should reset password" do
    users(:user1).password = 'new password'
    users(:user1).password_confirmation = 'new password'
    users(:user1).save
    users(:user1).valid_password?('new password').should be_true
  end

  it "should reset checkout_icalendar_token" do
    users(:user1).reset_checkout_icalendar_token
    users(:user1).checkout_icalendar_token.should be_true
  end

  it "should reset answer_feed_token" do
    users(:user1).reset_answer_feed_token
    users(:user1).answer_feed_token.should be_true
  end

  it "should delete checkout_icalendar_token" do
    users(:user1).delete_checkout_icalendar_token
    users(:user1).checkout_icalendar_token.should be_nil
  end

  it "should delete answer_feed_token" do
    users(:user1).delete_answer_feed_token
    users(:user1).answer_feed_token.should be_nil
  end

  it "should get checked_item_count" do
    count = users(:user1).checked_item_count
    count.should eq({:book=>2, :serial=>1, :cd=>0})
  end

  it "should set temporary_password" do
    user = users(:user1)
    old_password = user.encrypted_password
    user.set_auto_generated_password
    user.save
    old_password.should_not eq user.encrypted_password
    user.valid_password?('user1password').should be_false
  end

  it "should get reserves_count" do
    users(:user1).reserves.waiting.count.should eq 1
  end

  it "should get highest_role" do
    users(:admin).role.name.should eq 'Administrator'
  end

  it "should send_message" do
    assert users(:librarian1).send_message('reservation_expired_for_patron', :manifestations => users(:librarian1).reserves.not_sent_expiration_notice_to_patron.collect(&:manifestation))
    users(:librarian1).reload
    users(:librarian1).reserves.not_sent_expiration_notice_to_patron.should be_empty
  end

  it "should lock all expired users" do
    User.lock_expired_users
    users(:user4).active_for_authentication?.should be_false
  end

  it "should lock_expired users" do
    user = users(:user1)
    users(:user1).active_for_authentication?.should be_true
    user.expired_at = 1.day.ago
    user.save
    users(:user1).active_for_authentication?.should be_false
  end
end
