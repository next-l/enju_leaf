FactoryBot.define do
  factory :import_request do |f|
    f.sequence(:isbn){|n| "isbn_#{n}"}
  end
end
