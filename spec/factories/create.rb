FactoryGirl.define do
  factory :create do |f|
    f.work_id{FactoryGirl.create(:manifestation).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
