class UserCheckoutStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :user_checkout_stat, inverse_of: :user_checkout_stat_transitions
end

# == Schema Information
#
# Table name: user_checkout_stat_transitions
#
#  id                    :bigint           not null, primary key
#  to_state              :string
#  metadata              :text             default({})
#  sort_key              :integer
#  user_checkout_stat_id :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  most_recent           :boolean          not null
#
