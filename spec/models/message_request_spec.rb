require 'rails_helper'

describe MessageRequest do
  fixtures :all

  before(:each) do
    @message_request = FactoryBot.create(:message_request)
  end

  it 'should send_message' do
    @message_request.send_message.should be_truthy
  end

end

# == Schema Information
#
# Table name: message_requests
#
#  id                  :bigint           not null, primary key
#  sender_id           :bigint
#  receiver_id         :bigint
#  message_template_id :bigint
#  sent_at             :datetime
#  body                :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
