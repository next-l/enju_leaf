class Participate < ApplicationRecord
  belongs_to :agent
  belongs_to :event

  validates :agent_id, :event_id, presence: true
  validates :agent_id, uniqueness: { scope: :event_id }
  acts_as_list scope: :event_id

  paginates_per 10
end

# == Schema Information
#
# Table name: participates
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  event_id   :integer          not null
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#
