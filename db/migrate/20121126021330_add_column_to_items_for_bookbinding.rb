class AddColumnToItemsForBookbinding < ActiveRecord::Migration
  def up
    add_column :items, :bookbinder_id, :integer
    add_column :items, :bookbinder, :boolean, :default => false
  end

  def down
    remove_column :items, :bookbinder_id
    remove_column :items, :bookbinder
  end
end
