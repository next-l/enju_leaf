class CheckoutStatHasManifestation < ActiveRecord::Base
  belongs_to :manifestation_checkout_stat
  belongs_to :manifestation, :class_name => 'Manifestation'

  validates_uniqueness_of :manifestation_id, :scope => :manifestation_checkout_stat_id
  validates_presence_of :manifestation_checkout_stat_id, :manifestation_id

  paginates_per 10
end
