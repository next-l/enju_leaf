FactoryBot.define do
  factory :shelf do |f|
    f.sequence(:name){|n| "shelf_#{n}"}
    f.library_id{FactoryBot.create(:library).id}
  end
end
