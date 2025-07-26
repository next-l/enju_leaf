require 'rails_helper'

describe Produce do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: produces
#
#  id               :bigint           not null, primary key
#  position         :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  agent_id         :bigint           not null
#  manifestation_id :bigint           not null
#  produce_type_id  :bigint
#  name             :text
#
# Indexes
#
#  index_produces_on_agent_id                       (agent_id)
#  index_produces_on_manifestation_id_and_agent_id  (manifestation_id,agent_id) UNIQUE
#
