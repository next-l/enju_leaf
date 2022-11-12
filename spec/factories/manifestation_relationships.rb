FactoryBot.define do
  factory :manifestation_relationship do
    parent_id{FactoryBot.create(:manifestation).id}
    child_id{FactoryBot.create(:manifestation).id}
    association :manifestation_relationship_type
  end
end

# == Schema Information
#
# Table name: manifestation_relationships
#
#  id                                 :integer          not null, primary key
#  parent_id                          :integer
#  child_id                           :integer
#  manifestation_relationship_type_id :integer
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  position                           :integer
#
