class ReserveStatHasManifestation < ApplicationRecord
  belongs_to :manifestation_reserve_stat
  belongs_to :manifestation

  validates :manifestation_id, uniqueness: { scope: :manifestation_reserve_stat_id }

  paginates_per 10
end

# == Schema Information
#
# Table name: reserve_stat_has_manifestations
#
#  id                            :integer          not null, primary key
#  manifestation_reserve_stat_id :integer          not null
#  manifestation_id              :integer          not null
#  reserves_count                :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#
