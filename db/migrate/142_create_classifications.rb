class CreateClassifications < ActiveRecord::Migration[4.2]
  def up
    create_table :classifications do |t|
      t.integer :parent_id
      t.string :category, null: false
      t.text :note
      t.integer :classification_type_id, null: false

      t.timestamps
    end
    add_index :classifications, :parent_id
    add_index :classifications, :category
    add_index :classifications, :classification_type_id
  end

  def down
    drop_table :classifications
  end
end
