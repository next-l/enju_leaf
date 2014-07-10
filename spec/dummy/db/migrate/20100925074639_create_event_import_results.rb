class CreateEventImportResults < ActiveRecord::Migration
  def self.up
    create_table :event_import_results do |t|
      t.integer :event_import_file_id
      t.integer :event_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :event_import_results
  end
end
