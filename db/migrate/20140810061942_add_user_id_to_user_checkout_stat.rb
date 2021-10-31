class AddUserIdToUserCheckoutStat < ActiveRecord::Migration[4.2]
  def change
    add_reference :user_checkout_stats, :user, index: true, foreign_key: true
    add_reference :user_reserve_stats, :user, index: true, foreign_key: true
    add_reference :manifestation_checkout_stats, :user, index: true, foreign_key: true
    add_reference :manifestation_reserve_stats, :user, index: true, foreign_key: true
  end
end
