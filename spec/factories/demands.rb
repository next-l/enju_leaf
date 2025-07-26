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
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  item_id    :bigint
#  message_id :bigint
#  user_id    :bigint
#
# Indexes
#
#  index_demands_on_item_id     (item_id)
#  index_demands_on_message_id  (message_id)
#  index_demands_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (message_id => messages.id)
#  fk_rails_...  (user_id => users.id)
#
