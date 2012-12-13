# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :remove_reason do
    name "MyString"
    display_name "MyText"
    note "MyText"
    position 1
  end
end
