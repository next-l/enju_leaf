FactoryBot.define do
  factory :place do |f|
    f.sequence(:term) { |n| "term_#{n}" }
  end
end
