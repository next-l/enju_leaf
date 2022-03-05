FactoryBot.define do
  factory :news_feed do |f|
    f.sequence(:title){|n| "news_feed_#{n}"}
    f.sequence(:url){|n| "http://www.example.com/feed/#{n}"}
  end
end

# == Schema Information
#
# Table name: news_feeds
#
#  id               :integer          not null, primary key
#  library_group_id :integer          default(1), not null
#  title            :string
#  url              :string
#  body             :text
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#
