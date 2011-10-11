FactoryGirl.define do
  factory :reserve do |f|
    f.manifestation_id{FactoryGirl.create(:manifestation).id}
    f.user_id{FactoryGirl.create(:user).id}
  end
end
