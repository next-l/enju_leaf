FactoryGirl.define do
  factory :event do |f|
    f.sequence(:name){|n| "event_#{n}"}
    f.library_id{FactoryGirl.create(:library).id}
    f.event_category_id{FactoryGirl.create(:event_category).id}
  end

  factory :closing_day, :class => Event do |f|
    f.sequence(:name){|n| "event_#{n}"}
    f.event_category_id{FactoryGirl.create(:closing_event_category).id}
    f.all_day true
  end
end
