FactoryBot.define do
  factory :carrier_type_has_checkout_type do |f|
    f.carrier_type_id {FactoryBot.create(:carrier_type).id}
    f.checkout_type_id {FactoryBot.create(:checkout_type).id}
  end
end

# == Schema Information
#
# Table name: carrier_type_has_checkout_types
#
#  id               :bigint           not null, primary key
#  note             :text
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  carrier_type_id  :bigint           not null
#  checkout_type_id :bigint           not null
#
# Indexes
#
#  index_carrier_type_has_checkout_types_on_carrier_type_id   (carrier_type_id,checkout_type_id) UNIQUE
#  index_carrier_type_has_checkout_types_on_checkout_type_id  (checkout_type_id)
#
# Foreign Keys
#
#  fk_rails_...  (carrier_type_id => carrier_types.id)
#  fk_rails_...  (checkout_type_id => checkout_types.id)
#
