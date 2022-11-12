FactoryBot.define do
  factory :realize do |f|
    f.expression_id{FactoryBot.create(:manifestation).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: realizes
#
#  id              :integer          not null, primary key
#  agent_id        :integer          not null
#  expression_id   :integer          not null
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  realize_type_id :integer
#
