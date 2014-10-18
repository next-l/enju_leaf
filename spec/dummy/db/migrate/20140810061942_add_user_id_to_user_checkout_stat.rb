class AddUserIdToUserCheckoutStat < ActiveRecord::Migration
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
