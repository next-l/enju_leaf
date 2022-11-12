FactoryBot.define do
  factory :news_post do |f|
    f.sequence(:title){|n| "news_post_#{n}"}
    f.sequence(:body){|n| "news_post_#{n}"}
    f.user{FactoryBot.create(:librarian)}
  end
end

# == Schema Information
#
# Table name: news_posts
#
#  id               :integer          not null, primary key
#  title            :text
#  body             :text
#  user_id          :integer
#  start_date       :datetime
#  end_date         :datetime
#  required_role_id :integer          default(1), not null
#  note             :text
#  position         :integer
#  draft            :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  url              :string
#
