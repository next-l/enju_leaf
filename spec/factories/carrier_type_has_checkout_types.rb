FactoryBot.define do
  factory :carrier_type_has_checkout_type do |f|
    f.carrier_type_id{FactoryBot.create(:carrier_type).id}
    f.checkout_type_id{FactoryBot.create(:checkout_type).id}
  end
end

# == Schema Information
#
# Table name: carrier_type_has_checkout_types
#
#  id               :integer          not null, primary key
#  carrier_type_id  :integer          not null
#  checkout_type_id :integer          not null
#  note             :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#
