class Subscribe < ApplicationRecord
  belongs_to :subscription, counter_cache: true
  belongs_to :work, class_name: 'Manifestation'

  validates :start_at, :end_at, presence: true
  validates_uniqueness_of :work_id, scope: :subscription_id
end

# == Schema Information
#
# Table name: subscribes
#
#  id              :integer          not null, primary key
#  subscription_id :integer          not null
#  work_id         :integer          not null
#  start_at        :datetime         not null
#  end_at          :datetime         not null
#  created_at      :datetime
#  updated_at      :datetime
#
