class CreateEventExportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :event_export_files do |t|
      t.references :user, index: true
      t.attachment :event_export
      t.datetime :executed_at

      t.timestamps
    end
  end
end
