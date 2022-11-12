FactoryBot.define do
  factory :produce do |f|
    f.manifestation_id{FactoryBot.create(:manifestation).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: produces
#
#  id               :bigint           not null, primary key
#  agent_id         :bigint           not null
#  manifestation_id :bigint           not null
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  produce_type_id  :integer
#
