FactoryBot.define do
  factory :agent_relationship_type do |f|
    f.sequence(:name){|n| "agent_relationship_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: agent_relationship_types
#
#  id           :integer          not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
