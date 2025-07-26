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
#  checkout_renewal_count :integer          default(0), not null
#  due_date               :datetime
#  lock_version           :integer          default(0), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  basket_id              :bigint
#  checkin_id             :bigint
#  item_id                :bigint           not null
#  librarian_id           :bigint
#  library_id             :bigint
#  shelf_id               :bigint
#  user_id                :bigint
#
# Indexes
#
#  index_checkouts_on_basket_id                          (basket_id)
#  index_checkouts_on_checkin_id                         (checkin_id)
#  index_checkouts_on_item_id                            (item_id)
#  index_checkouts_on_item_id_and_basket_id_and_user_id  (item_id,basket_id,user_id) UNIQUE
#  index_checkouts_on_librarian_id                       (librarian_id)
#  index_checkouts_on_library_id                         (library_id)
#  index_checkouts_on_shelf_id                           (shelf_id)
#  index_checkouts_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (checkin_id => checkins.id)
#  fk_rails_...  (item_id => items.id)
#  fk_rails_...  (library_id => libraries.id)
#  fk_rails_...  (shelf_id => shelves.id)
#  fk_rails_...  (user_id => users.id)
#
