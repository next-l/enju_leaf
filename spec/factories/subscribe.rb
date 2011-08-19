FactoryGirl.define do
  factory :subscribe do |f|
    f.subscription{FactoryGirl.create(:subscription)}
    f.work{FactoryGirl.create(:manifestation)}
    f.start_at 1.year.ago
    f.end_at 1.year.from_now
  end
end
