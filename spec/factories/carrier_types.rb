FactoryBot.define do
  factory :carrier_type do |f|
    f.sequence(:name){|n| "carrier_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: carrier_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
