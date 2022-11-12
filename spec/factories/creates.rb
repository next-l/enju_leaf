FactoryBot.define do
  factory :create do
    work_id{FactoryBot.create(:manifestation).id}
    agent_id{FactoryBot.create(:agent).id}
    association :create_type
  end
end

# == Schema Information
#
# Table name: creates
#
#  id             :bigint           not null, primary key
#  agent_id       :integer          not null
#  work_id        :integer          not null
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  create_type_id :integer
#
