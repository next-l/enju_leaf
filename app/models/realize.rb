class Realize < ApplicationRecord
  belongs_to :agent
  belongs_to :expression, class_name: "Manifestation", touch: true
  belongs_to :realize_type, optional: true

  validates :expression_id, uniqueness: { scope: :agent_id }
  after_destroy :reindex
  after_save :reindex

  acts_as_list scope: :expression

  def reindex
    agent.try(:index)
    expression.try(:index)
  end
end

# == Schema Information
#
# Table name: realizes
#
#  id              :bigint           not null, primary key
#  name            :text
#  position        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  agent_id        :bigint           not null
#  expression_id   :bigint           not null
#  realize_type_id :bigint
#
# Indexes
#
#  index_realizes_on_agent_id                    (agent_id)
#  index_realizes_on_expression_id_and_agent_id  (expression_id,agent_id) UNIQUE
#
