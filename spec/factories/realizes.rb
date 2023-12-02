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
#  id              :bigint           not null, primary key
#  agent_id        :bigint           not null
#  expression_id   :bigint           not null
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  realize_type_id :bigint
#  name            :text
#
