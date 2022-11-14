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
#  id                     :bigint           not null, primary key
#  user_id                :bigint
#  item_id                :bigint           not null
#  checkin_id             :integer
#  librarian_id           :bigint
#  basket_id              :bigint
#  due_date               :datetime
#  checkout_renewal_count :integer          default(0), not null
#  lock_version           :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  shelf_id               :integer
#  library_id             :bigint
#
