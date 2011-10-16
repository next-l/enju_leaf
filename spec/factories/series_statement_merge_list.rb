FactoryGirl.define do
  factory :series_statement_merge_list do |f|
    f.sequence(:title){|n| "series_statement_merge_list_#{n}"}
  end
end
