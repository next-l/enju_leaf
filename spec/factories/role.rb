FactoryGirl.define do
  factory :required_user, :class => 'Role' do |f|
    f.sequence(:name){|n| "user_#{n}"}
    f.sequence(:display_name){|n| "user_#{n}"}
    f.score 2
  end
end
