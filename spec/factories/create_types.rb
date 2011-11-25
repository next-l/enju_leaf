# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :create_type do
    name "MyString"
    display_name "MyText"
    note "MyText"
    position 1
  end
end
