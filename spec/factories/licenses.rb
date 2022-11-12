FactoryBot.define do
  factory :license do |f|
    f.sequence(:name){|n| "license_#{n}"}
  end
end

# == Schema Information
#
# Table name: licenses
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :string
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
