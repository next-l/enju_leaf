class AgentType < ApplicationRecord
  include MasterModel
  has_many :agents, dependent: :restrict_with_exception
end

# == Schema Information
#
# Table name: agent_types
#
#  id           :bigint           not null, primary key
#  name         :string           not null
#  display_name :text
#  note         :text
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
