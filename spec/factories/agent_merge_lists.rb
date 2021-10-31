FactoryBot.define do
  factory :agent_merge_list do |f|
    f.sequence(:title){|n| "agent_merge_list_#{n}"}
  end
end

# == Schema Information
#
# Table name: agent_merge_lists
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#
