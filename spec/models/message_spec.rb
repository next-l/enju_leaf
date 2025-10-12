require 'rails_helper'

describe Message do
  fixtures :all

  before(:each) do
    @message = FactoryBot.create(:message)
  end

  it 'should require body' do
    @message.errors[:body].should be_truthy
  end

  it 'should require recipient' do
    @message.errors[:recipient].should be_truthy
  end

  it 'should require subject' do
    @message.errors[:subject].should be_truthy
  end

  it 'should return sender_name' do
    @message.sender.username.should be_truthy
  end

  it 'should return receiver_name' do
    @message.receiver = users(:user1)
    @message.receiver.username.should be_truthy
  end

  it 'should set read_at' do
    message = messages(:user2_to_user1_1)
    message.transition_to!(:read)
    message.read_at.should be_truthy
    message.read?.should be_truthy
    message.current_state.should eq 'read'
  end

  it 'should require valid recipient' do
    @message.recipient = 'invalidusername'
    @message.save.should be_falsy
  end
end

# == Schema Information
#
# Table name: messages
#
#  id                 :bigint           not null, primary key
#  body               :text
#  depth              :integer
#  lft                :integer
#  read_at            :datetime
#  rgt                :integer
#  subject            :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  message_request_id :bigint
#  parent_id          :bigint
#  receiver_id        :bigint
#  sender_id          :bigint
#
# Indexes
#
#  index_messages_on_message_request_id  (message_request_id)
#  index_messages_on_parent_id           (parent_id)
#  index_messages_on_receiver_id         (receiver_id)
#  index_messages_on_sender_id           (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_id => messages.id)
#
