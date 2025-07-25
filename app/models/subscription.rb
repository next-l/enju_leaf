class Subscription < ApplicationRecord
  has_many :subscribes, dependent: :destroy
  has_many :works, through: :subscribes
  belongs_to :user
  if defined?(EnjuPurchasRequest)
    belongs_to :order_list
  end

  validates :title, presence: :title

  searchable do
    text :title, :note
    time :created_at
    time :updated_at
    integer :work_ids, multiple: true
  end

  paginates_per 10

  def subscribed(work)
    subscribes.find_by(work_id: work.id)
  end
end

# == Schema Information
#
# Table name: subscriptions
#
#  id               :bigint           not null, primary key
#  note             :text
#  subscribes_count :integer          default(0), not null
#  title            :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  order_list_id    :bigint
#  user_id          :bigint           not null
#
# Indexes
#
#  index_subscriptions_on_order_list_id  (order_list_id)
#  index_subscriptions_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
