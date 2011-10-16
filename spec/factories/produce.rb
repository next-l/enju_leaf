FactoryGirl.define do
  factory :produce do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
