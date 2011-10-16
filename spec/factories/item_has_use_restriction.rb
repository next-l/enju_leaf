FactoryGirl.define do
  factory :item_has_use_restriction do |f|
    f.item_id{FactoryGirl.create(:item).id}
    f.use_restriction_id{FactoryGirl.create(:use_restriction).id}
  end
end
