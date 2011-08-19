FactoryGirl.define do
  factory :patron_merge do |f|
    f.patron_merge_list{FactoryGirl.create(:patron_merge_list)}
    f.patron{FactoryGirl.create(:patron)}
  end
end
