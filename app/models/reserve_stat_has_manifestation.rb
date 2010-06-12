class ReserveStatHasManifestation < ActiveRecord::Base
  belongs_to :manifestation_reserve_stat
  belongs_to :manifestation, :class_name => 'Resource'

  validates_uniqueness_of :manifestation_id, :scope => :manifestation_reserve_stat_id

  def self.per_page
    10
  end
end
