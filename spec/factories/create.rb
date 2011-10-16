FactoryGirl.define do
  factory :create do |f|
    f.work{FactoryGirl.create(:manifestation)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
