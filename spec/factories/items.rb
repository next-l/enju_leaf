FactoryBot.define do
  factory :item do
    sequence(:item_identifier) {|n| "item_#{n}"}
    circulation_status_id {CirculationStatus.find(1).id}
    manifestation_id {FactoryBot.create(:manifestation).id}
    after(:build) do |item|
      bookstore = Bookstore.find(1)
      budget_type = BudgetType.find(1)
      item.use_restriction = UseRestriction.find_by(name: 'Limited Circulation, Normal Loan Period')
    end
  end
end

# == Schema Information
#
# Table name: items
#
#  id                      :bigint           not null, primary key
#  acquired_at             :datetime
#  binded_at               :datetime
#  binding_call_number     :string
#  binding_item_identifier :string
#  call_number             :string
#  include_supplements     :boolean          default(FALSE), not null
#  item_identifier         :string
#  lock_version            :integer          default(0), not null
#  memo                    :text
#  missing_since           :date
#  note                    :text
#  price                   :integer
#  required_score          :integer          default(0), not null
#  url                     :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  bookstore_id            :bigint
#  budget_type_id          :bigint
#  checkout_type_id        :bigint           default(1), not null
#  circulation_status_id   :bigint           default(5), not null
#  manifestation_id        :bigint           not null
#  required_role_id        :bigint           default(1), not null
#  shelf_id                :bigint           default(1), not null
#
# Indexes
#
#  index_items_on_binding_item_identifier  (binding_item_identifier)
#  index_items_on_bookstore_id             (bookstore_id)
#  index_items_on_checkout_type_id         (checkout_type_id)
#  index_items_on_circulation_status_id    (circulation_status_id)
#  index_items_on_item_identifier          (item_identifier) UNIQUE WHERE (((item_identifier)::text <> ''::text) AND (item_identifier IS NOT NULL))
#  index_items_on_manifestation_id         (manifestation_id)
#  index_items_on_required_role_id         (required_role_id)
#  index_items_on_shelf_id                 (shelf_id)
#
# Foreign Keys
#
#  fk_rails_...  (manifestation_id => manifestations.id)
#  fk_rails_...  (required_role_id => roles.id)
#
