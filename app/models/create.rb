class Create < ApplicationRecord
  belongs_to :agent
  belongs_to :work, class_name: 'Manifestation', touch: true
  belongs_to :create_type, optional: true

  validates :agent_id, uniqueness: { scope: :work_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :work

  def reindex
    agent.try(:index)
    work.try(:index)
  end
end

# == Schema Information
#
# Table name: creates
#
#  id             :integer          not null, primary key
#  agent_id       :integer          not null
#  work_id        :integer          not null
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  create_type_id :integer
#
