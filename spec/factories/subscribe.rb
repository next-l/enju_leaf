FactoryBot.define do
  factory :subscribe do |f|
    f.subscription_id{FactoryBot.create(:subscription).id}
    f.work_id{FactoryBot.create(:manifestation).id}
    f.start_at { 1.year.ago }
    f.end_at { 1.year.from_now }
  end
end
