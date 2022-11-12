class Own < ApplicationRecord
  belongs_to :agent
  belongs_to :item

  validates :agent_id, uniqueness: { scope: :item_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :item

  attr_accessor :item_identifier

  def reindex
    agent.try(:index)
    item.try(:index)
  end
end

# == Schema Information
#
# Table name: owns
#
#  id         :integer          not null, primary key
#  agent_id   :integer          not null
#  item_id    :integer          not null
#  position   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
