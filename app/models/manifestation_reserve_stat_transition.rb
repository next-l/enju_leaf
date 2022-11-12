class ManifestationReserveStatTransition < ApplicationRecord
  include Statesman::Adapters::ActiveRecordTransition

  
  belongs_to :manifestation_reserve_stat, inverse_of: :manifestation_reserve_stat_transitions
end

# == Schema Information
#
# Table name: manifestation_reserve_stat_transitions
#
#  id                            :integer          not null, primary key
#  to_state                      :string
#  metadata                      :text             default({})
#  sort_key                      :integer
#  manifestation_reserve_stat_id :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  most_recent                   :boolean          not null
#
