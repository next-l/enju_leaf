FactoryGirl.define do
  factory :patron_merge do |f|
    f.patron_merge_list_id{FactoryGirl.create(:patron_merge_list).id}
    f.patron_id{FactoryGirl.create(:patron).id}
  end
end
