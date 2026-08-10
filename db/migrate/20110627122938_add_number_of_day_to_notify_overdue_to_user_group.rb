class AddNumberOfDayToNotifyOverdueToUserGroup < ActiveRecord::Migration[4.2]
  def up
    add_column :user_groups, :number_of_day_to_notify_overdue, :integer, default: 0, null: false
    add_column :user_groups, :number_of_day_to_notify_due_date, :integer, default: 0, null: false
    add_column :user_groups, :number_of_time_to_notify_overdue, :integer, default: 0, null: false
  end

  def down
    remove_column :user_groups, :number_of_time_to_notify_overdue
    remove_column :user_groups, :number_of_day_to_notify_due_date
    remove_column :user_groups, :number_of_day_to_notify_overdue
  end
end
