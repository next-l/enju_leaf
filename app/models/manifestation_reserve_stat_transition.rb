class ManifestationReserveStatTransition < ApplicationRecord
  belongs_to :manifestation_reserve_stat, inverse_of: :manifestation_reserve_stat_transitions
end

# == Schema Information
#
# Table name: manifestation_reserve_stat_transitions
#
#  id                            :bigint           not null, primary key
#  to_state                      :string
#  metadata                      :jsonb            not null
#  sort_key                      :integer
#  manifestation_reserve_stat_id :bigint
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  most_recent                   :boolean          not null
#
