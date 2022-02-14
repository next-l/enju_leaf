class Produce < ApplicationRecord
  belongs_to :agent
  belongs_to :manifestation, touch: true
  belongs_to :produce_type, optional: true
  delegate :original_title, to: :manifestation, prefix: true

  validates :manifestation_id, uniqueness: { scope: :agent_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :manifestation

  def reindex
    agent.try(:index)
    manifestation.try(:index)
  end
end

# == Schema Information
#
# Table name: produces
#
#  id               :integer          not null, primary key
#  agent_id         :integer          not null
#  manifestation_id :integer          not null
#  position         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  produce_type_id  :integer
#
