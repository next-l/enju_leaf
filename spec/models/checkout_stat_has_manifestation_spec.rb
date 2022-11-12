require 'rails_helper'

describe CheckoutStatHasManifestation do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: checkout_stat_has_manifestations
#
#  id                             :integer          not null, primary key
#  manifestation_checkout_stat_id :integer          not null
#  manifestation_id               :integer          not null
#  checkouts_count                :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
