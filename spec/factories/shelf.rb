FactoryGirl.define do
  factory :shelf do |f|
    f.sequence(:name){|n| "shelf_#{n}"}
    f.sequence(:library){FactoryGirl.create(:library)}
  end
end
