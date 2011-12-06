class AddUserGroupOnStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :user_group_id, :integer
  end

  def self.down
    remove_column :statistics, :user_group_id
  end
end
