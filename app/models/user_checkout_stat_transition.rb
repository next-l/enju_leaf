class UserCheckoutStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_checkout_stat, inverse_of: :user_checkout_stat_transitions
  # attr_accessible :to_state, :sort_key, :metadata
end

# == Schema Information
#
# Table name: user_checkout_stat_transitions
#
#  id                    :integer          not null, primary key
#  to_state              :string
#  metadata              :text             default({})
#  sort_key              :integer
#  user_checkout_stat_id :integer
#  created_at            :datetime
#  updated_at            :datetime
#  most_recent           :boolean          not null
#
