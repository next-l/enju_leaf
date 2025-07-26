FactoryBot.define do
  factory :participate do |f|
    f.event_id {FactoryBot.create(:event).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: participates
#
#  id         :bigint           not null, primary key
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  agent_id   :bigint           not null
#  event_id   :bigint           not null
#
# Indexes
#
#  index_participates_on_agent_id  (agent_id)
#  index_participates_on_event_id  (event_id)
#
