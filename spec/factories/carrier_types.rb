FactoryBot.define do
  factory :carrier_type do |f|
    f.sequence(:name) {|n| "carrier_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: carrier_types
#
#  id           :bigint           not null, primary key
#  display_name :text
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_carrier_types_on_lower_name  (lower((name)::text)) UNIQUE
#
