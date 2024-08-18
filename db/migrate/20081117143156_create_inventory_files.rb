class CreateInventoryFiles < ActiveRecord::Migration[4.2]
  def up
    create_table :inventory_files, if_not_exists: true do |t|
      t.references :user, index: true
      t.text :note

      t.timestamps
    end
  end

  def down
    drop_table :inventory_files
  end
end
