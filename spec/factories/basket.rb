FactoryGirl.define do
  factory :basket do |f|
    f.user_id{FactoryGirl.create(:user).id}
  end
end
