FactoryGirl.define do
  factory :country do |f|
    f.sequence(:name){|n| "country_#{n}"}
    f.sequence(:alpha_2){|n| "alpha_2_#{n}"}
    f.sequence(:alpha_3){|n| "alpha_3_#{n}"}
    f.sequence(:numeric_3){|n| "numeric_3_#{n}"}
  end
end
