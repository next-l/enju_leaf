FactoryGirl.define do
  factory :item_has_use_restriction do |f|
    f.item{FactoryGirl.create(:item)}
    f.use_restriction{FactoryGirl.create(:use_restriction)}
  end
end
