FactoryGirl.define do
  factory :message_template do |f|
    f.sequence(:title){|n| "message_template_#{n}"}
    f.sequence(:status){|n| "message_template_#{n}"}
    f.sequence(:body){|n| "message_template_#{n}"}
  end
end
