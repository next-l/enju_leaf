FactoryGirl.define do
  factory :bookstore do |f|
    f.sequence(:name){|n| "bookstore_#{n}"}
  end
end
