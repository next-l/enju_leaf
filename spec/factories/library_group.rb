FactoryGirl.define do
  factory :library_group do |f|
    f.sequence(:name){|n| "library_group_#{n}"}
    f.sequence(:display_name){|n| "library_group_#{n}"}
    f.sequence(:email){|n| "library_group_#{n}@example.jp"}
    f.sequence(:short_name){|n| "libg_#{n}"}
  end
end
