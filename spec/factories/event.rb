FactoryGirl.define do
  factory :event do |f|
    f.sequence(:name){|n| "event_#{n}"}
    f.library_id{FactoryGirl.create(:library).id}
    f.event_category_id{FactoryGirl.create(:event_category).id}
  end
end
