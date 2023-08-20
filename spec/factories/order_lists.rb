FactoryBot.define do
  factory :order_list do |f|
    f.user_id{FactoryBot.create(:user).id}
    f.sequence(:title){|n| "order_list_#{n}"}
    f.bookstore_id{FactoryBot.create(:bookstore).id}
  end
end

# == Schema Information
#
# Table name: order_lists
#
#  id           :bigint           not null, primary key
#  user_id      :bigint           not null
#  bookstore_id :bigint           not null
#  title        :text             not null
#  note         :text
#  ordered_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
