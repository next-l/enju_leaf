FactoryGirl.define do
  factory :patron_relationship do |f|
    f.parent{FactoryGirl.create(:patron)}
    f.child{FactoryGirl.create(:patron)}
  end
end
