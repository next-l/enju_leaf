FactoryBot.define do
  factory :produce do |f|
    f.manifestation_id {FactoryBot.create(:manifestation).id}
    f.agent_id {FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: produces
#
#  id               :bigint           not null, primary key
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  agent_id         :bigint           not null
#  manifestation_id :bigint           not null
#  produce_type_id  :bigint
#
# Indexes
#
#  index_produces_on_agent_id                       (agent_id)
#  index_produces_on_manifestation_id_and_agent_id  (manifestation_id,agent_id) UNIQUE
#
