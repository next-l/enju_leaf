class UserReserveStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_reserve_stat, inverse_of: :user_reserve_stat_transitions
  # attr_accessible :to_state, :sort_key, :metadata
end

# == Schema Information
#
# Table name: user_reserve_stat_transitions
#
#  id                   :integer          not null, primary key
#  to_state             :string
#  metadata             :text             default({})
#  sort_key             :integer
#  user_reserve_stat_id :integer
#  created_at           :datetime
#  updated_at           :datetime
#  most_recent          :boolean          not null
#
