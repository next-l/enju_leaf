FactoryGirl.define do
  factory :inter_library_loan do |f|
    f.item{FactoryGirl.create(:item)}
    f.to_library{FactoryGirl.create(:library)}
    f.from_library{FactoryGirl.create(:library)}
  end
end
