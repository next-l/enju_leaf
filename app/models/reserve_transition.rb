class ReserveTransition < ApplicationRecord
  belongs_to :reserve, inverse_of: :reserve_transitions
end

# == Schema Information
#
# Table name: reserve_transitions
#
#  id          :bigint           not null, primary key
#  to_state    :string
#  metadata    :jsonb            not null
#  sort_key    :integer
#  reserve_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  most_recent :boolean          not null
#
