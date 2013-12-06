class AddUserTypeToStatistics < ActiveRecord::Migration
  def self.up
    add_column :statistics, :user_type, :integer
  end

  def self.down
    remove_column :statistics, :user_type
  end
end
