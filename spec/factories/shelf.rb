FactoryGirl.define do
  factory :shelf do |f|
    f.sequence(:name){|n| "shelf_#{n}"}
    f.library_id{FactoryGirl.create(:library).id}
    f.open_access 0
  end
end
