FactoryBot.define do
  factory :create do
    work_id {FactoryBot.create(:manifestation).id}
    agent_id {FactoryBot.create(:agent).id}
    association :create_type
  end
end

# == Schema Information
#
# Table name: creates
#
#  id             :bigint           not null, primary key
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  agent_id       :bigint           not null
#  create_type_id :bigint
#  work_id        :bigint           not null
#
# Indexes
#
#  index_creates_on_agent_id              (agent_id)
#  index_creates_on_work_id_and_agent_id  (work_id,agent_id) UNIQUE
#
