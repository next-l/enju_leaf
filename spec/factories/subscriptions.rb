FactoryBot.define do
  factory :subscription do |f|
    f.sequence(:title){|n| "subscription_#{n}"}
    f.user_id{FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: subscriptions
#
#  id               :integer          not null, primary key
#  title            :text             not null
#  note             :text
#  user_id          :integer
#  order_list_id    :integer
#  subscribes_count :integer          default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#
