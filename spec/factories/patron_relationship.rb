FactoryGirl.define do
  factory :patron_relationship do |f|
    f.parent_id{FactoryGirl.create(:patron).id}
    f.child_id{FactoryGirl.create(:patron).id}
  end
end
