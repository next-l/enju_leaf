class CreateEventImportResults < ActiveRecord::Migration[4.2]
  def up
    create_table :event_import_results do |t|
      t.references :event_import_file
      t.references :event
      t.text :body

      t.timestamps
    end
  end

  def down
    drop_table :event_import_results
  end
end
