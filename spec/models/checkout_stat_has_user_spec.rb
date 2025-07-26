require 'rails_helper'

describe CheckoutStatHasUser do
  # pending "add some examples to (or delete) #{__FILE__}"

end

# == Schema Information
#
# Table name: checkout_stat_has_users
#
#  id                    :bigint           not null, primary key
#  checkouts_count       :integer          default(0), not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  user_checkout_stat_id :bigint           not null
#  user_id               :bigint           not null
#
# Indexes
#
#  index_checkout_stat_has_users_on_user_checkout_stat_id  (user_checkout_stat_id)
#  index_checkout_stat_has_users_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_checkout_stat_id => user_checkout_stats.id)
#  fk_rails_...  (user_id => users.id)
#
