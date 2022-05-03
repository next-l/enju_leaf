class NewsFeed < ApplicationRecord
  default_scope { order("news_feeds.position") }
  belongs_to :library_group

  validates :title, :url, presence: true
  validates :url, length: { maximum: 255 }
  before_save :fetch

  acts_as_list

  def self.per_page
    10
  end

  def fetch
    begin
      feed = Faraday.get(url).body.force_encoding('UTF-8')
      if rss = RSS::Parser.parse(feed, false)
        self.body = feed
      end
    rescue StandardError, Timeout::Error
      nil
    end
  end

  def content
    if body
    # tDiary の RSS をパースした際に to_s が空になる
    # rss = RSS::Parser.parse(feed)
    # rss.to_s
    # => ""
    # if rss.nil?
      begin
        rss = RSS::Parser.parse(body)
      rescue RSS::InvalidRSSError
        rss = RSS::Parser.parse(body, false)
      rescue RSS::NotWellFormedError, TypeError
        nil
      end
    # end
    end
  end

  def force_reload
    save!
  end

  def self.fetch_feeds
    NewsFeed.find_each do |news_feed|
      news_feed.touch
    end
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
