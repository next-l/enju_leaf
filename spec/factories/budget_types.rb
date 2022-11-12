FactoryBot.define do
  factory :budget_type do |f|
    f.sequence(:name){|n| "budget_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: budget_types
#
#  id           :integer          not null, primary key
#  name         :string
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
