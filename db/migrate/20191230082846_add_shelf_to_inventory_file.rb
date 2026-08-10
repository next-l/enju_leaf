class AddShelfToInventoryFile < ActiveRecord::Migration[5.2]
  def up
    add_reference :inventory_files, :shelf, foreign_key: true, if_not_exists: true
  end

  def down
    remove_reference :inventory_files, :shelf
  end
end
