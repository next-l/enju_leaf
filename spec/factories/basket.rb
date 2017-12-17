FactoryBot.define do
  factory :basket do |f|
    f.user_id{FactoryBot.create(:user).id}
  end
end
