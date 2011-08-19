FactoryGirl.define do
  factory :manifestation_relationship do |f|
    f.parent{FactoryGirl.create(:manifestation)}
    f.child{FactoryGirl.create(:manifestation)}
  end
end
