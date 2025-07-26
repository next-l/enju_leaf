require 'rails_helper'

describe Realize do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: realizes
#
#  id              :bigint           not null, primary key
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
