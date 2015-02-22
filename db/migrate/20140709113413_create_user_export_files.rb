class CreateUserExportFiles < ActiveRecord::Migration
  def change
    create_table :user_export_files do |t|
      t.integer :user_id
      t.attachment :user_export
      t.datetime :executed_at

      t.timestamps
    end
  end
end
