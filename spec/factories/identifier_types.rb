FactoryBot.define do
  factory :identifier_type do |f|
    f.sequence(:name){|n| "identifier_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: identifier_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
