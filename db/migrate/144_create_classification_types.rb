class CreateClassificationTypes < ActiveRecord::Migration[4.2]
  def up
    create_table :classification_types do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
  end

  def down
    drop_table :classification_types
  end
end
