FactoryBot.define do
  factory :question do |f|
    f.sequence(:body){|n| "question_#{n}"}
    f.user_id{FactoryBot.create(:user).id}
  end
end

# == Schema Information
#
# Table name: questions
#
#  id            :integer          not null, primary key
#  user_id       :integer          not null
#  body          :text
#  shared        :boolean          default(TRUE), not null
#  answers_count :integer          default(0), not null
#  deleted_at    :datetime
#  state         :string
#  solved        :boolean          default(FALSE), not null
#  note          :text
#  created_at    :datetime
#  updated_at    :datetime
#
