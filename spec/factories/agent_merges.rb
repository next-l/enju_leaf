FactoryBot.define do
  factory :agent_merge do |f|
    f.agent_merge_list_id{FactoryBot.create(:agent_merge_list).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: agent_merges
#
#  id                  :integer          not null, primary key
#  agent_id            :integer          not null
#  agent_merge_list_id :integer          not null
#  created_at          :datetime
#  updated_at          :datetime
#
