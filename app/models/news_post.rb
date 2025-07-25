class NewsPost < ApplicationRecord
  scope :published, -> { where(draft: false) }
  scope :current, -> { where("start_date <= ? AND end_date >= ?", Time.zone.now, Time.zone.now) }
  default_scope { order("news_posts.start_date DESC") }
  belongs_to :user
  belongs_to :required_role, class_name: "Role"

  validates :title, :body, presence: true
  validate :check_date

  acts_as_list

  searchable do
    text :title, :body
    time :start_date, :end_date
  end

  def self.per_page
    10
  end

  def check_date
    if start_date && end_date
      self.end_date = end_date.end_of_day
      if start_date >= end_date
        errors.add(:start_date)
        errors.add(:end_date)
      end
    end
  end
end

# == Schema Information
#
# Table name: news_posts
#
#  id               :bigint           not null, primary key
#  body             :text
#  draft            :boolean          default(FALSE), not null
#  end_date         :datetime
#  note             :text
#  position         :integer
#  start_date       :datetime
#  title            :text
#  url              :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  required_role_id :bigint           default(1), not null
#  user_id          :bigint           not null
#
# Indexes
#
#  index_news_posts_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (required_role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#
