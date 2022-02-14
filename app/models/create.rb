class Create < ApplicationRecord
  belongs_to :agent
  belongs_to :work, class_name: 'Manifestation', touch: true
  belongs_to :create_type, optional: true

  validates :work_id, uniqueness: { scope: :agent_id }
  after_save :reindex
  after_destroy :reindex

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
#  created_at     :datetime
#  updated_at     :datetime
#  create_type_id :integer
#
