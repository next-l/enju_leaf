# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :numbering do
    name "MyString"
    display_name "MyString"
    prefix "MyString"
    suffix "MyString"
    padding ""
    padding_number 1
    last_number 1
    checkdigit 1
  end
end
