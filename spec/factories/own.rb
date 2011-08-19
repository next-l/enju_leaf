FactoryGirl.define do
  factory :own do |f|
    f.item{FactoryGirl.create(:item)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
