require 'rails_helper'

describe CheckoutStatHasManifestation do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: checkout_stat_has_manifestations
#
#  id                             :bigint           not null, primary key
#  manifestation_checkout_stat_id :bigint           not null
#  manifestation_id               :bigint           not null
#  checkouts_count                :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#
