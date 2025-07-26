FactoryBot.define do
  factory :order_list do |f|
    f.user_id {FactoryBot.create(:user).id}
    f.sequence(:title) {|n| "order_list_#{n}"}
    f.bookstore_id {FactoryBot.create(:bookstore).id}
  end
end

# == Schema Information
#
# Table name: order_lists
#
#  id           :bigint           not null, primary key
#  note         :text
#  ordered_at   :datetime
#  title        :text             not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  bookstore_id :bigint           not null
#  user_id      :bigint           not null
#
# Indexes
#
#  index_order_lists_on_bookstore_id  (bookstore_id)
#  index_order_lists_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (bookstore_id => bookstores.id)
#  fk_rails_...  (user_id => users.id)
#
