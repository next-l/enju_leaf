class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.string :action
      t.string :subject_class
      t.integer :subject_id
      t.integer :role_id

      t.timestamps
    end
    add_index :permissions, :role_id
    add_index :permissions, [:action, :subject_class, :subject_id]
  end
end
