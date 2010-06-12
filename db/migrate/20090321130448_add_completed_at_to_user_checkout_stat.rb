class AddCompletedAtToUserCheckoutStat < ActiveRecord::Migration
  def self.up
    add_column :user_checkout_stats, :started_at, :datetime
    add_column :user_checkout_stats, :completed_at, :datetime
    add_index :user_checkout_stats, :state
    add_column :user_reserve_stats, :started_at, :datetime
    add_column :user_reserve_stats, :completed_at, :datetime
    add_index :user_reserve_stats, :state
    add_column :manifestation_checkout_stats, :started_at, :datetime
    add_column :manifestation_checkout_stats, :completed_at, :datetime
    add_index :manifestation_checkout_stats, :state
    add_column :manifestation_reserve_stats, :started_at, :datetime
    add_column :manifestation_reserve_stats, :completed_at, :datetime
    add_index :manifestation_reserve_stats, :state
    add_column :bookmark_stats, :started_at, :datetime
    add_column :bookmark_stats, :completed_at, :datetime
    add_index :bookmark_stats, :state
  end

  def self.down
    remove_column :user_checkout_stats, :started_at
    remove_column :user_checkout_stats, :completed_at
    remove_column :user_reserve_stats, :started_at
    remove_column :user_reserve_stats, :completed_at
    remove_column :manifestation_checkout_stats, :started_at
    remove_column :manifestation_checkout_stats, :completed_at
    remove_column :manifestation_reserve_stats, :started_at
    remove_column :manifestation_reserve_stats, :completed_at
    remove_column :bookmark_stats, :started_at
    remove_column :bookmark_stats, :completed_at
  end
end
