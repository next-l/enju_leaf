FactoryGirl.define do
  factory :donate do |f|
    f.item{FactoryGirl.create(:item)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
