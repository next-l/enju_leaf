FactoryBot.define do
  factory :demand do
    user_id { FactoryBot.create(:user).id }
    item_id { FactoryBot.create(:item).id }
    message_id { FactoryBot.create(:message).id }
  end
end

# == Schema Information
#
# Table name: demands
#
#  id         :bigint           not null, primary key
#  user_id    :integer
#  item_id    :integer
#  message_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
