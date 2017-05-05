class AddNumberOfDayToNotifyOverdueToUserGroup < ActiveRecord::Migration
  def self.up
    add_column :user_groups, :number_of_day_to_notify_overdue, :integer, default: 1, null: false
    add_column :user_groups, :number_of_day_to_notify_due_date, :integer, default: 7, null: false
    add_column :user_groups, :number_of_time_to_notify_overdue, :integer, default: 3, null: false
  end

  def self.down
    remove_column :user_groups, :number_of_time_to_notify_overdue
    remove_column :user_groups, :number_of_day_to_notify_due_date
    remove_column :user_groups, :number_of_day_to_notify_overdue
  end
end
