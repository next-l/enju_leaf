# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sequence_manage do
    keystr "MyString"
    value 1
    prefix "MyString"
  end
end
