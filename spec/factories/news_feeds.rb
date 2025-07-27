FactoryBot.define do
  factory :news_feed do |f|
    f.sequence(:title) {|n| "news_feed_#{n}"}
    f.sequence(:url) {|n| "http://www.example.com/feed/#{n}"}
  end
end

# == Schema Information
#
# Table name: news_feeds
#
#  id               :bigint           not null, primary key
#  body             :text
#  position         :integer
#  title            :string
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  library_group_id :bigint           default(1), not null
#
