class CreateUserExportFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :user_export_files do |t|
      t.references :user, foreign_key: true
      t.attachment :user_export
      t.datetime :executed_at

      t.timestamps
    end
  end
end
