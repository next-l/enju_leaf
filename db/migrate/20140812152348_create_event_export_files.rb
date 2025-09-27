class CreateEventExportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :event_export_files do |t|
      t.references :user, index: true
      t.string :event_export_content_type
      t.string :event_export_file_name
      t.bigint :event_export_file_size
      t.datetime :event_export_updated_at
      t.datetime :executed_at

      t.timestamps
    end
  end
end
