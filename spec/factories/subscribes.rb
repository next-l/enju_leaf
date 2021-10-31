FactoryBot.define do
  factory :subscribe do |f|
    f.subscription_id{FactoryBot.create(:subscription).id}
    f.work_id{FactoryBot.create(:manifestation).id}
    f.start_at { 1.year.ago }
    f.end_at { 1.year.from_now }
  end
end

# == Schema Information
#
# Table name: subscribes
#
#  id              :integer          not null, primary key
#  subscription_id :integer          not null
#  work_id         :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  created_at      :datetime
#  updated_at      :datetime
#
