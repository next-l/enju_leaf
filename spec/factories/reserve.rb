FactoryGirl.define do
  factory :reserve do |f|
    f.manifestation{FactoryGirl.create(:manifestation)}
    f.user{FactoryGirl.create(:user)}
  end
end
