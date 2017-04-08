class CreateUserExportFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :user_export_files do |t|
      t.integer :user_id
      t.datetime :executed_at

      t.timestamps
    end
  end
end
