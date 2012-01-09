class CreateEventImportResults < ActiveRecord::Migration
  def change
    create_table :event_import_results do |t|
      t.integer :event_import_file_id
      t.integer :event_id
      t.text :body

      t.timestamps
    end
  end
end
