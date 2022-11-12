class ReserveTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :reserve, inverse_of: :reserve_transitions
end

# == Schema Information
#
# Table name: reserve_transitions
#
#  id          :integer          not null, primary key
#  to_state    :string
#  metadata    :text             default({})
#  sort_key    :integer
#  reserve_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  most_recent :boolean          not null
#
