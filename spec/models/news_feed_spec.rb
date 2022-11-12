require 'rails_helper'

describe NewsFeed do
  fixtures :news_feeds

  it "should get content", vcr: true do
    feed = news_feeds(:news_feed_00001)
    feed.force_reload
    feed.content.should be_truthy
  end

  it "should not get content if the feed is invalid", vcr: true do
    feed = news_feeds(:news_feed_00002)
    feed.force_reload
    feed.content.should be_nil
  end

  it "should reload content", vcr: true do
    news_feeds(:news_feed_00001).force_reload.should be_truthy
  end

  it "should fetch feeds", vcr: true do
    expect(NewsFeed.fetch_feeds).to be_nil
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
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
