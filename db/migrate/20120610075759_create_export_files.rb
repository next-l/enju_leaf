class CreateExportFiles < ActiveRecord::Migration
  def change
    create_table :export_files do |t|
      t.string :export_file_name
      t.string :export_content_type
      t.string :export_file_size
      t.string :state

      t.timestamps
    end
  end
end
