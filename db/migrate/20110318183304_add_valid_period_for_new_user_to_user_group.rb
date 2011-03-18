class AddValidPeriodForNewUserToUserGroup < ActiveRecord::Migration
  def self.up
    add_column :user_groups, :valid_period_for_new_user, :integer, :default => 0, :null => false
    add_column :user_groups, :expired_at, :timestamp
    remove_column :library_groups, :valid_period_for_new_user
  end

  def self.down
    remove_column :user_groups, :valid_period_for_new_user
    remove_column :user_groups, :expired_at
    add_column :library_groups, :valid_period_for_new_user, :integer, :default => 0, :null => false
  end
end
