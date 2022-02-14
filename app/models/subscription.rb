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
#  id               :integer          not null, primary key
#  title            :text             not null
#  note             :text
#  user_id          :integer
#  order_list_id    :integer
#  deleted_at       :datetime
#  subscribes_count :integer          default(0), not null
#  created_at       :datetime
#  updated_at       :datetime
#
