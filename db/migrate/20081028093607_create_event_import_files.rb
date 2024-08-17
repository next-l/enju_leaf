class CreateEventImportFiles < ActiveRecord::Migration[4.2]
  def up
    create_table :event_import_files do |t|
      t.references :parent, index: true
      t.references :user, index: true
      t.text :note
      t.datetime :imported_at
      t.string :edit_mode

      t.timestamps
    end
  end

  def down
    drop_table :event_import_files
  end
end
