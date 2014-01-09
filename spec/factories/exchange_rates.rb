# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exchange_rate do
    id 1
    currency_id 1
    rate "9.99"
    started_at "2014-01-08 10:16:39"
    created_at "2014-01-08 10:16:39"
    updated_at "2014-01-08 10:16:39"
  end
end
