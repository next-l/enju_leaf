# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :manifestation_type do |f|
    f.name "MyString"
    f.display_name "MyText"
    f.note "MyText"
    f.position 1
  end
end
