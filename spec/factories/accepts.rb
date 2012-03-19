# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :accept do
    basket_id{FactoryGirl.create(:basket).id}
    item_id{FactoryGirl.create(:item).id}
    librarian_id{FactoryGirl.create(:librarian).id}
  end
end
