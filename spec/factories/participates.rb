FactoryBot.define do
  factory :participate do |f|
    f.event_id{FactoryBot.create(:event).id}
    f.agent_id{FactoryBot.create(:agent).id}
  end
end

# == Schema Information
#
# Table name: participates
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  event_id   :integer          not null
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#