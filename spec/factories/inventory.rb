FactoryGirl.define do
  factory :inventory do |f|
    f.inventory_file_id 1
    f.item_id{FactoryGirl.create(:item).id}
  end
end
