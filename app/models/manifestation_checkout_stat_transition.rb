class ManifestationCheckoutStatTransition < ApplicationRecord
  belongs_to :manifestation_checkout_stat, inverse_of: :manifestation_checkout_stat_transitions
end

# == Schema Information
#
# Table name: manifestation_checkout_stat_transitions
#
#  id                             :bigint           not null, primary key
#  metadata                       :jsonb            not null
#  most_recent                    :boolean          not null
#  sort_key                       :integer
#  to_state                       :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  manifestation_checkout_stat_id :bigint
#
# Indexes
#
#  index_manifestation_checkout_stat_transitions_on_stat_id        (manifestation_checkout_stat_id)
#  index_manifestation_checkout_stat_transitions_on_transition     (sort_key,manifestation_checkout_stat_id) UNIQUE
#  index_manifestation_checkout_stat_transitions_parent_most_rece  (manifestation_checkout_stat_id,most_recent) UNIQUE WHERE most_recent
#
