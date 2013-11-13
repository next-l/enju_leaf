# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :theme do
    name "MyString"
    description "MyText"
    publish 1
    note "MyText"
    position 1
  end
end
