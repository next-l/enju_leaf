class AddUserStatusId < ActiveRecord::Migration
  def up
    add_column :users, :user_status_id, :integer, :default => 1, :null => false
    add_column :user_statuses, :state_id, :integer, :default => 1, :null => false
  end

  def down
    remove_column :users, :user_status_id
    remove_column :user_statuses, :state_id
  end
end
