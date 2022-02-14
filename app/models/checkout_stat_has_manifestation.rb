class CheckoutStatHasManifestation < ApplicationRecord
  belongs_to :manifestation_checkout_stat
  belongs_to :manifestation

  validates :manifestation_id, uniqueness: { scope: :manifestation_checkout_stat_id }

  paginates_per 10
end

# == Schema Information
#
# Table name: checkout_stat_has_manifestations
#
#  id                             :integer          not null, primary key
#  manifestation_checkout_stat_id :integer          not null
#  manifestation_id               :integer          not null
#  checkouts_count                :integer
#  created_at                     :datetime
#  updated_at                     :datetime
#
