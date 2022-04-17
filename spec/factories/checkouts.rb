FactoryBot.define do
  factory :checkout, class: Checkout do |f|
    f.due_date { Time.zone.now.next_week }
    f.association :item, factory: :item
    f.association :user, factory: :user
    f.association :librarian, factory: :librarian
    f.association :basket, factory: :basket
  end
end

# == Schema Information
#
# Table name: checkouts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  item_id                :integer          not null
#  checkin_id             :integer
#  librarian_id           :integer
#  basket_id              :integer
#  due_date               :datetime
#  checkout_renewal_count :integer          default(0), not null
#  lock_version           :integer          default(0), not null
#  created_at             :datetime
#  updated_at             :datetime
#  shelf_id               :integer
#  library_id             :integer
#
