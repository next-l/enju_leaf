FactoryBot.define do
  factory :agent_type do |f|
    f.sequence(:name) {|n| "agent_type_#{n}"}
  end
end

# == Schema Information
#
# Table name: agent_types
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
#  index_agent_types_on_lower_name  (lower((name)::text)) UNIQUE
#
