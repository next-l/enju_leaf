class CreateResourceExportFiles < ActiveRecord::Migration
  def change
    create_table :resource_export_files do |t|
      t.integer :user_id
      t.datetime :executed_at

      t.timestamps
    end
  end
end
