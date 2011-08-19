FactoryGirl.define do
  factory :form_of_work do |f|
    f.sequence(:name){|n| "form_of_work_#{n}"}
  end
end
