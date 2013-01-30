class AddMailSentAtToReminderList < ActiveRecord::Migration
  def up
    add_column :reminder_lists, :mail_sent_at, :timestamp
  end

  def down
    remove_column :reminder_lists, :mail_sent_at
  end
end
