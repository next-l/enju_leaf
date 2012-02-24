FactoryGirl.define do
  factory :message_request do |f|
    f.sender_id{FactoryGirl.create(:user).id}
    f.receiver_id{FactoryGirl.create(:user).id}
    f.message_template_id{FactoryGirl.create(:message_template).id}
  end
end
