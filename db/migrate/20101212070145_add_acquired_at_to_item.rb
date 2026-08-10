class AddAcquiredAtToItem < ActiveRecord::Migration[4.2]
  def up
    add_column :items, :acquired_at, :timestamp
  end

  def down
    remove_column :items, :acquired_at
  end
end
