class CreateResourceExportFiles < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_export_files do |t|
      t.integer :user_id
      t.string :resource_export_content_type
      t.string :resource_export_file_name
      t.integer :resource_export_file_size
      t.datetime :executed_at

      t.timestamps
    end
  end
end
