class UserCheckoutStatTransition < ApplicationRecord
  belongs_to :user_checkout_stat, inverse_of: :user_checkout_stat_transitions
end

# == Schema Information
#
# Table name: user_checkout_stat_transitions
#
#  id                    :bigint           not null, primary key
#  metadata              :jsonb            not null
#  most_recent           :boolean          not null
#  sort_key              :integer
#  to_state              :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_checkout_stat_id :bigint
#
# Indexes
#
#  index_user_checkout_stat_transitions_on_sort_key_and_stat_id   (sort_key,user_checkout_stat_id) UNIQUE
#  index_user_checkout_stat_transitions_on_user_checkout_stat_id  (user_checkout_stat_id)
#  index_user_checkout_stat_transitions_parent_most_recent        (user_checkout_stat_id,most_recent) UNIQUE WHERE most_recent
#
