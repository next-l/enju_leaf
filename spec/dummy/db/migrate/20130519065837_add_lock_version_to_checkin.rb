class AddLockVersionToCheckin < ActiveRecord::Migration
  def change
    add_column :checkins, :lock_version, :integer, default: 0, null: false
  end
end
