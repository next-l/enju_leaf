class CreateNiiTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :nii_types, if_not_exists: true do |t|
      t.string :name, null: false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :nii_types, :name, unique: true, if_not_exists: true
  end
end
