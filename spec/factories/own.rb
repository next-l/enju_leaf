FactoryGirl.define do
  factory :own do |f|
    f.item_id{FactoryGirl.create(:item).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
