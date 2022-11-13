FactoryBot.define do
  factory :agent_relationship do |f|
    f.parent_id{FactoryBot.create(:agent).id}
    f.child_id{FactoryBot.create(:agent).id}
    f.association :agent_relationship_type
  end
end

# == Schema Information
#
# Table name: agent_relationships
#
#  id                         :bigint           not null, primary key
#  parent_id                  :integer
#  child_id                   :integer
#  agent_relationship_type_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  position                   :integer
#
