class AddUserIdOnStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :user_id, :integer
  end

  def self.down
    remove_column :statistics, :user_id
  end
end
