require 'rails_helper'

describe AgentRelationship do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: agent_relationships
#
#  id                         :bigint           not null, primary key
#  parent_id                  :integer
#  child_id                   :integer
#  agent_relationship_type_id :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  position                   :integer
#
