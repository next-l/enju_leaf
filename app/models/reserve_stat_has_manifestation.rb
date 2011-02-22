class ReserveStatHasManifestation < ActiveRecord::Base
  belongs_to :manifestation_reserve_stat
  belongs_to :manifestation, :class_name => 'Manifestation'

  validates_uniqueness_of :manifestation_id, :scope => :manifestation_reserve_stat_id

  paginates_per 10
end
