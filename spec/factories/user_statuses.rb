# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_status do |f|
    f.name "MyString"
    f.display_name "MyString"
    f.state_id 1
  end
end
