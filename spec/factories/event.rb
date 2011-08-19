FactoryGirl.define do
  factory :event do |f|
    f.sequence(:name){|n| "event_#{n}"}
    f.library{FactoryGirl.create(:library)}
    f.event_category{FactoryGirl.create(:event_category)}
  end
end
