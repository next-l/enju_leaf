if defined?(Tag)

FactoryGirl.define do
  factory :tag do |f|
    f.sequence(:name){|n| "tag_#{n}"}
  end
end

end
