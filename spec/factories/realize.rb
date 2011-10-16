FactoryGirl.define do
  factory :realize do |f|
    f.expression{FactoryGirl.create(:manifestation)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
