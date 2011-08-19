FactoryGirl.define do
  factory :inter_library_loan do |f|
    f.item{FactoryGirl.create(:item)}
    f.borrowing_library{FactoryGirl.create(:library)}
  end
end
