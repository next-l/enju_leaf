FactoryGirl.define do
  factory :message_request do |f|
    f.sequence(:sender){FactoryGirl.create(:user)}
    f.sequence(:receiver){FactoryGirl.create(:user)}
    f.sequence(:message_template){FactoryGirl.create(:message_template)}
  end
end
