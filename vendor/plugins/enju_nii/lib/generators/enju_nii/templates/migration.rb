class CreateNiiTypeMigration < ActiveRecord::Migration
  def self.up
    create_table :nii_types do |t|
      t.string :name, :null => false
      t.text :display_name
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :nii_types, :name, :unique => true

    add_column :manifestations, :nii_type_id, :integer
    add_index :manifestations, :nii_type_id
  end

  def self.down
    drop_table :nii_types

    remove_column :manifestations, :nii_type_id
  end
end
