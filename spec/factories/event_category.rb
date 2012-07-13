FactoryGirl.define do
  factory :event_category do |f|
    f.sequence(:name){|n| "event_category_#{n}"}
  end

  factory :closing_event_category, :class => EventCategory do |f|
    f.sequence(:name){|n| "closing_#{n}"}
    f.checkin_ng true
  end
end
