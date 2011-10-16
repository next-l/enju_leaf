FactoryGirl.define do
  factory :produce do |f|
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
