class Subscribe < ApplicationRecord
  belongs_to :subscription, counter_cache: true
  belongs_to :work, class_name: "Manifestation"

  validates :start_at, :end_at, presence: true
  validates :work_id, uniqueness: { scope: :subscription_id }
end

# == Schema Information
#
# Table name: subscribes
#
#  id              :bigint           not null, primary key
#  end_at          :datetime         not null
#  start_at        :datetime         not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  subscription_id :bigint           not null
#  work_id         :bigint           not null
#
# Indexes
#
#  index_subscribes_on_subscription_id  (subscription_id)
#  index_subscribes_on_work_id          (work_id)
#
