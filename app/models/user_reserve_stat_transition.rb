class UserReserveStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_reserve_stat, inverse_of: :user_reserve_stat_transitions
end

# == Schema Information
#
# Table name: user_reserve_stat_transitions
#
#  id                   :bigint           not null, primary key
#  to_state             :string
#  metadata             :text             default({})
#  sort_key             :integer
#  user_reserve_stat_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  most_recent          :boolean          not null
#
