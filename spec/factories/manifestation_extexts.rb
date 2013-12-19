# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :manifestation_extext do
    name "MyString"
    value "MyText"
    manifestation_id 1
    position 1
  end
end
