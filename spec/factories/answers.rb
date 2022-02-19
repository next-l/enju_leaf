FactoryBot.define do
  factory :answer do |f|
    f.sequence(:body){|n| "answer_#{n}"}
    f.question_id{FactoryBot.create(:question).id}
    f.user_id{FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: answers
#
#  id                   :integer          not null, primary key
#  user_id              :integer          not null
#  question_id          :integer          not null
#  body                 :text
#  created_at           :datetime
#  updated_at           :datetime
#  deleted_at           :datetime
#  shared               :boolean          default(TRUE), not null
#  state                :string
#  item_identifier_list :text
#  url_list             :text
#
