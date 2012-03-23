FactoryGirl.define do
  factory :reserve do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.user{FactoryGirl.create(:user)}
    f.expired_at 1.week.from_now
    f.created_by 1
  end
end
