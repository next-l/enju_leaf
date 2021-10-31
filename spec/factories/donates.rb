FactoryBot.define do
  factory :donate do |f|
    f.item_id{FactoryBot.create(:item).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: donates
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  item_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
