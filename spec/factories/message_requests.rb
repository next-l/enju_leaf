FactoryBot.define do
  factory :message_request do
    sender_id{FactoryBot.create(:user).id}
    receiver_id{FactoryBot.create(:user).id}
    message_template_id{FactoryBot.create(:message_template).id}
    body { 'test' }
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
