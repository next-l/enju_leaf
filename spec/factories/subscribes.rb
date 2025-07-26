FactoryBot.define do
  factory :subscribe do |f|
    f.subscription_id {FactoryBot.create(:subscription).id}
    f.work_id {FactoryBot.create(:manifestation).id}
    f.start_at { 1.year.ago }
    f.end_at { 1.year.from_now }
  end
end

# == Schema Information
#
# Table name: subscribes
#
#  id              :bigint           not null, primary key
#  end_at          :datetime         not null
#  start_at        :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subscription_id :bigint           not null
#  work_id         :bigint           not null
#
# Indexes
#
#  index_subscribes_on_subscription_id  (subscription_id)
#  index_subscribes_on_work_id          (work_id)
#
