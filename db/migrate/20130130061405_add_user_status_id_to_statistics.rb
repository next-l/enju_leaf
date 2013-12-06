class AddUserStatusIdToStatistics < ActiveRecord::Migration
  def change
    add_column :statistics, :user_status_id, :integer
  end
end
