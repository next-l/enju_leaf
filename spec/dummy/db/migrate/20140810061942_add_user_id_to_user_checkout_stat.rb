class AddUserIdToUserCheckoutStat < ActiveRecord::Migration[5.0]
  def change
    add_column :user_checkout_stats, :user_id, :integer
    add_column :user_reserve_stats, :user_id, :integer
    add_column :manifestation_checkout_stats, :user_id, :integer
    add_column :manifestation_reserve_stats, :user_id, :integer
    add_index :user_checkout_stats, :user_id
    add_index :user_reserve_stats, :user_id
    add_index :manifestation_checkout_stats, :user_id
    add_index :manifestation_reserve_stats, :user_id
  end
end
