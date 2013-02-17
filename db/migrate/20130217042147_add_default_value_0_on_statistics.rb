class AddDefaultValue0OnStatistics < ActiveRecord::Migration
  def up
    change_column :statistics, :checkout_type_id, :integer, :default => 0
    change_column :statistics, :shelf_id, :integer, :default => 0
    change_column :statistics, :age, :integer, :default => 0
    change_column :statistics, :user_group_id, :integer, :default => 0
    change_column :statistics, :user_type, :integer, :default => 0
    change_column :statistics, :user_id, :integer, :default => 0
    change_column :statistics, :department_id, :integer, :default => 0
    change_column :statistics, :manifestation_type_id, :integer, :default => 0
    change_column :statistics, :user_status_id, :integer, :default => 0
  end

  def down
  end
end
