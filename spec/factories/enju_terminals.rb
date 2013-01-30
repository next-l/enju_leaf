# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :terminal do
    ipaddr "MyString"
    name "MyString"
    comment "MyString"
    checkouts_autoprint false
    reserve_autoprint false
    manifestation_autoprint false
  end
end
