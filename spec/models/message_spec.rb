require 'spec_helper'

describe Message do
  fixtures :all

  before(:each) do
    @message = Factory(:message)
  end

  it "should require body" do
    @message.errors[:body].should be_true
  end

  it "should require recipient" do
    @message.errors[:recipient].should be_true
  end

  it "should require subject" do
    @message.errors[:subject].should be_true
  end
  
  it "should return sender_name" do
    @message.sender.username.should be_true
  end

  it "should return receiver_name" do
    @message.receiver = users(:user1)
    @message.receiver.username.should be_true
  end
  
  it "should set read_at" do
    message = messages(:user2_to_user1_1)
    message.sm_read!
    message.read_at.should be_true
    message.read?.should be_true
    message.state.should eq 'read'
  end
end
