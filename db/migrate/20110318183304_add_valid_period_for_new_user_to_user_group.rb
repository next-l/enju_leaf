class AddValidPeriodForNewUserToUserGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :user_groups, :valid_period_for_new_user, :integer, default: 0, null: false
    add_column :user_groups, :expired_at, :timestamp
  end

  def down
    remove_column :user_groups, :valid_period_for_new_user
    remove_column :user_groups, :expired_at
  end
end
