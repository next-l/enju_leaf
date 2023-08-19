FactoryBot.define do
  factory :purchase_request do |f|
    f.sequence(:title){|n| "purchase_request_#{n}"}
    f.user_id{FactoryBot.create(:user).id}
  end
end
