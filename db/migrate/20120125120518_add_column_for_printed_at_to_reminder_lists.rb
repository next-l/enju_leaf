class AddColumnForPrintedAtToReminderLists < ActiveRecord::Migration
  def self.up
    add_column :reminder_lists, :type1_printed_at, :timestamp
    add_column :reminder_lists, :type2_printed_at, :timestamp
  end

  def self.down
    remove_column :reminder_lists, :type1_printed_at
    remove_column :reminder_lists, :type2_printed_at
  end
end
