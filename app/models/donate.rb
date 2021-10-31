class Donate < ApplicationRecord
  belongs_to :agent
  belongs_to :item
  validates_associated :agent, :item
  validates_presence_of :agent, :item
end

# == Schema Information
#
# Table name: donates
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  item_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
