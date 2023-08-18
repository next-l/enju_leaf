require 'rails_helper'

describe AgentRelationship do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: agent_relationships
#
#  id                         :bigint           not null, primary key
#  parent_id                  :bigint
#  child_id                   :bigint
#  agent_relationship_type_id :bigint
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  position                   :integer
#
