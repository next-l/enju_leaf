class AddDeletedAtOnCheckedItems < ActiveRecord::Migration
  def self.up
    add_column :checked_items, :deleted_at, :datetime
  end

  def self.down
    remove_column :checked_items, :deleted_at
  end
end
