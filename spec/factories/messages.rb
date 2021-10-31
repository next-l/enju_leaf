FactoryBot.define do
  factory :message do
    recipient{FactoryBot.create(:user).username}
    sender{FactoryBot.create(:user)}
    subject { 'new message' }
    body { 'new message body is really short' }
    association :message_request
  end
end

# == Schema Information
#
# Table name: messages
#
#  id                 :bigint           not null, primary key
#  read_at            :datetime
#  sender_id          :bigint
#  receiver_id        :bigint
#  subject            :string           not null
#  body               :text
#  message_request_id :bigint
#  parent_id          :bigint
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  lft                :integer
#  rgt                :integer
#  depth              :integer
#
