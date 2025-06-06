FactoryBot.define do
  factory :license do |f|
    f.sequence(:name) {|n| "license_#{n}"}
  end
end

# == Schema Information
#
# Table name: licenses
#
#  id           :bigint           not null, primary key
#  display_name :string
#  name         :string           not null
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_licenses_on_lower_name  (lower((name)::text)) UNIQUE
#
