FactoryGirl.define do
  factory :participate do |f|
    f.event_id{FactoryGirl.create(:event).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
