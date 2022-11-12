FactoryBot.define do
  factory :own do |f|
    f.item_id{FactoryBot.create(:item).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: owns
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  item_id    :integer          not null
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
